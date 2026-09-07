package com.propvault.controller;

import com.propvault.dto.request.SubscribeRequest;
import com.propvault.dto.response.*;
import com.propvault.service.RazorpayService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController @RequestMapping("/payments") @RequiredArgsConstructor
public class PaymentController {
    private final RazorpayService razorpayService;

    @PostMapping("/subscribe")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Map<String, Object>> subscribe(@Valid @RequestBody SubscribeRequest req) {
        return ResponseEntity.ok(razorpayService.createSubscription(req));
    }

    @PostMapping("/verify")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<SubscriptionResponse> verify(@RequestBody Map<String, String> payload) {
        return ResponseEntity.ok(razorpayService.verifyAndActivate(payload));
    }

    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(@RequestBody String payload,
            @RequestHeader("X-Razorpay-Signature") String sig) {
        razorpayService.handleWebhook(payload, sig);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/cancel")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Void> cancel() {
        razorpayService.cancelSubscription(); return ResponseEntity.noContent().build();
    }

    @GetMapping("/invoices")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Page<InvoiceResponse>> invoices(@RequestParam(defaultValue="0") int page) {
        return ResponseEntity.ok(razorpayService.getInvoices(page));
    }
}
