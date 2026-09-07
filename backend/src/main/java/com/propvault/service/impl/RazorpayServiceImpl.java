package com.propvault.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.propvault.dto.request.SubscribeRequest;
import com.propvault.dto.response.*;
import com.propvault.entity.*;
import com.propvault.enums.SubscriptionStatus;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.service.RazorpayService;
import com.propvault.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.*;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service @RequiredArgsConstructor @Slf4j
public class RazorpayServiceImpl implements RazorpayService {

    private final SubscriptionRepository subRepo;
    private final SubscriptionPlanRepository planRepo;
    private final InvoiceRepository invoiceRepo;
    private final AgentRepository agentRepo;
    private final SecurityUtil securityUtil;
    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate;

    @Value("${propvault.razorpay.key-id}")       private String keyId;
    @Value("${propvault.razorpay.key-secret}")    private String keySecret;
    @Value("${propvault.razorpay.webhook-secret}") private String webhookSecret;
    @Value("${propvault.gst-percent:18.0}")        private double gstPercent;

    private static final String RAZORPAY_BASE = "https://api.razorpay.com/v1";

    @Override @Transactional
    public Map<String, Object> createSubscription(SubscribeRequest req) {
        Agent agent = getCurrentAgent();
        SubscriptionPlan plan = planRepo.findById(req.getPlanId())
            .orElseThrow(() -> ApiException.notFound("Plan not found"));

        String razorpayPlanId = req.isYearly() ? plan.getRazorpayPlanIdYearly() : plan.getRazorpayPlanIdMonthly();
        if (razorpayPlanId == null)
            throw ApiException.badRequest("Plan not configured with Razorpay. Contact support.");

        // Build Razorpay subscription request
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("plan_id", razorpayPlanId);
        body.put("total_count", req.isYearly() ? 12 : 120); // cycles
        body.put("quantity", 1);

        Map<String, Object> addons = new LinkedHashMap<>();
        double gst = plan.getPriceMonthly().doubleValue() * gstPercent / 100;
        addons.put("item", Map.of("name", "GST 18%", "amount", (int)(gst * 100), "currency", "INR"));
        body.put("addons", List.of(addons));

        // Call Razorpay API
        Map<String, Object> razorpayResponse = callRazorpay("POST", "/subscriptions", body);

        // Persist subscription record
        Subscription sub = subRepo.findByAgentId(agent.getId()).orElse(new Subscription());
        sub.setAgent(agent);
        sub.setPlan(plan);
        sub.setStatus(SubscriptionStatus.TRIAL);
        sub.setRazorpaySubscriptionId((String) razorpayResponse.get("id"));
        sub.setAutoRenew(true);
        sub.setYearly(req.isYearly());
        subRepo.save(sub);

        return Map.of(
            "subscriptionId", razorpayResponse.get("id"),
            "keyId", keyId,
            "planName", plan.getDisplayName(),
            "amount", req.isYearly() ? plan.getPriceYearly() : plan.getPriceMonthly(),
            "currency", "INR"
        );
    }

    @Override @Transactional
    public SubscriptionResponse verifyAndActivate(Map<String, String> payload) {
        String razorpayPaymentId    = payload.get("razorpay_payment_id");
        String razorpaySubscriptionId = payload.get("razorpay_subscription_id");
        String razorpaySignature    = payload.get("razorpay_signature");

        // Verify signature
        String data = razorpayPaymentId + "|" + razorpaySubscriptionId;
        if (!verifyHmacSha256(data, razorpaySignature, keySecret))
            throw ApiException.unauthorized("Payment signature verification failed");

        Subscription sub = subRepo.findByRazorpaySubscriptionId(razorpaySubscriptionId)
            .orElseThrow(() -> ApiException.notFound("Subscription not found"));

        BigDecimal amount = sub.getPlan().getPriceMonthly();
        BigDecimal gstAmt = amount.multiply(BigDecimal.valueOf(gstPercent / 100)).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total  = amount.add(gstAmt);

        sub.setStatus(SubscriptionStatus.ACTIVE);
        sub.setStartDate(LocalDate.now());
        sub.setCurrentPeriodEnd(sub.isYearly() ? LocalDate.now().plusYears(1) : LocalDate.now().plusMonths(1));
        sub.setLastPaymentAmount(total);
        sub.setLastPaymentAt(LocalDateTime.now());
        sub.setLastPaymentId(razorpayPaymentId);
        subRepo.save(sub);

        generateInvoice(sub, amount, gstAmt, total, razorpayPaymentId);

        return buildSubscriptionResponse(sub);
    }

    @Override
    public void handleWebhook(String payload, String signature) {
        if (!verifyHmacSha256(payload, signature, webhookSecret)) {
            log.warn("Invalid Razorpay webhook signature");
            throw ApiException.unauthorized("Invalid webhook signature");
        }
        try {
            JsonNode node = objectMapper.readTree(payload);
            String event = node.get("event").asText();
            log.info("Razorpay webhook: {}", event);

            switch (event) {
                case "subscription.charged" -> handleCharged(node);
                case "subscription.cancelled", "subscription.expired" -> handleCancelled(node);
                case "subscription.pending" -> handlePending(node);
                default -> log.debug("Unhandled webhook event: {}", event);
            }
        } catch (Exception e) {
            log.error("Webhook processing error: {}", e.getMessage());
        }
    }

    @Override @Transactional
    public void cancelSubscription() {
        Agent agent = getCurrentAgent();
        Subscription sub = subRepo.findByAgentId(agent.getId())
            .orElseThrow(() -> ApiException.notFound("No active subscription"));
        if (sub.getRazorpaySubscriptionId() != null)
            callRazorpay("POST", "/subscriptions/" + sub.getRazorpaySubscriptionId() + "/cancel", Map.of());
        sub.setStatus(SubscriptionStatus.CANCELLED);
        sub.setAutoRenew(false);
        subRepo.save(sub);
    }

    @Override
    public Page<InvoiceResponse> getInvoices(int page) {
        UUID agentId = securityUtil.getCurrentAgentId();
        Page<Invoice> invoicePage = invoiceRepo.findByAgentIdOrderByCreatedAtDesc(
            agentId, PageRequest.of(page, 10));
        return invoicePage.map(this::toInvoiceResponse);
    }

    // ── Private helpers ────────────────────────────────────────────────────────

    private void handleCharged(JsonNode node) {
        String subId = node.at("/payload/subscription/entity/id").asText();
        String payId = node.at("/payload/payment/entity/id").asText();
        subRepo.findByRazorpaySubscriptionId(subId).ifPresent(sub -> {
            sub.setStatus(SubscriptionStatus.ACTIVE);
            sub.setCurrentPeriodEnd(sub.isYearly() ? LocalDate.now().plusYears(1) : LocalDate.now().plusMonths(1));
            sub.setLastPaymentId(payId);
            sub.setLastPaymentAt(LocalDateTime.now());
            BigDecimal amount = sub.getPlan().getPriceMonthly();
            BigDecimal gstAmt = amount.multiply(BigDecimal.valueOf(gstPercent / 100)).setScale(2, RoundingMode.HALF_UP);
            sub.setLastPaymentAmount(amount.add(gstAmt));
            subRepo.save(sub);
            generateInvoice(sub, amount, gstAmt, amount.add(gstAmt), payId);
        });
    }

    private void handleCancelled(JsonNode node) {
        String subId = node.at("/payload/subscription/entity/id").asText();
        subRepo.findByRazorpaySubscriptionId(subId).ifPresent(sub -> {
            sub.setStatus(SubscriptionStatus.CANCELLED);
            subRepo.save(sub);
        });
    }

    private void handlePending(JsonNode node) {
        String subId = node.at("/payload/subscription/entity/id").asText();
        subRepo.findByRazorpaySubscriptionId(subId).ifPresent(sub -> {
            sub.setStatus(SubscriptionStatus.PAST_DUE);
            subRepo.save(sub);
        });
    }

    private void generateInvoice(Subscription sub, BigDecimal subtotal,
                                  BigDecimal gstAmt, BigDecimal total, String paymentId) {
        int seq = invoiceRepo.findMaxInvoiceNumber().orElse(0) + 1;
        String number = String.format("INV-%d-%06d", LocalDate.now().getYear(), seq);
        Invoice inv = Invoice.builder()
            .agent(sub.getAgent()).subscription(sub)
            .invoiceNumber(number).subtotal(subtotal)
            .gstPercent(BigDecimal.valueOf(gstPercent)).gstAmount(gstAmt)
            .totalAmount(total).razorpayPaymentId(paymentId)
            .status("PAID").invoiceDate(LocalDate.now())
            .build();
        invoiceRepo.save(inv);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> callRazorpay(String method, String path, Map<String, Object> body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String credentials = Base64.getEncoder().encodeToString((keyId + ":" + keySecret).getBytes());
        headers.set("Authorization", "Basic " + credentials);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        ResponseEntity<Map> resp = restTemplate.exchange(
            RAZORPAY_BASE + path, HttpMethod.valueOf(method), entity, Map.class);
        if (resp.getBody() == null) throw ApiException.badRequest("Razorpay returned empty response");
        return resp.getBody();
    }

    private boolean verifyHmacSha256(String data, String signature, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) hex.append(String.format("%02x", b));
            return hex.toString().equals(signature);
        } catch (Exception e) {
            log.error("HMAC verification failed: {}", e.getMessage());
            return false;
        }
    }

    private Agent getCurrentAgent() {
        return agentRepo.findByUserId(securityUtil.getCurrentUserId())
            .orElseThrow(() -> ApiException.notFound("Agent not found"));
    }

    private SubscriptionResponse buildSubscriptionResponse(Subscription sub) {
        SubscriptionResponse r = new SubscriptionResponse();
        r.setId(sub.getId()); r.setStatus(sub.getStatus());
        r.setStartDate(sub.getStartDate()); r.setCurrentPeriodEnd(sub.getCurrentPeriodEnd());
        r.setAutoRenew(sub.isAutoRenew()); r.setYearly(sub.isYearly());
        r.setLastPaymentAmount(sub.getLastPaymentAmount()); r.setLastPaymentAt(sub.getLastPaymentAt());
        if (sub.getPlan() != null) {
            r.setPlanName(sub.getPlan().getName()); r.setPlanDisplayName(sub.getPlan().getDisplayName());
            r.setPriceMonthly(sub.getPlan().getPriceMonthly()); r.setMaxListings(sub.getPlan().getMaxListings());
            r.setMaxFeaturedListings(sub.getPlan().getMaxFeaturedListings());
            r.setVideoUpload(sub.getPlan().isVideoUpload()); r.setAnalyticsAccess(sub.getPlan().isAnalyticsAccess());
        }
        return r;
    }

    private InvoiceResponse toInvoiceResponse(Invoice inv) {
        InvoiceResponse r = new InvoiceResponse();
        r.setId(inv.getId()); r.setInvoiceNumber(inv.getInvoiceNumber());
        r.setSubtotal(inv.getSubtotal()); r.setGstPercent(inv.getGstPercent());
        r.setGstAmount(inv.getGstAmount()); r.setTotalAmount(inv.getTotalAmount());
        r.setRazorpayPaymentId(inv.getRazorpayPaymentId());
        r.setStatus(inv.getStatus()); r.setInvoiceDate(inv.getInvoiceDate());
        r.setPdfUrl(inv.getPdfUrl()); r.setCreatedAt(inv.getCreatedAt());
        return r;
    }
}
