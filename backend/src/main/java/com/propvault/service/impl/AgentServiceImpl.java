package com.propvault.service.impl;

import com.propvault.dto.request.AgentProfileRequest;
import com.propvault.dto.response.*;
import com.propvault.entity.*;
import com.propvault.enums.*;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.service.*;
import com.propvault.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor
public class AgentServiceImpl implements AgentService {

    private final AgentRepository        agentRepo;
    private final PropertyRepository     propertyRepo;
    private final SubscriptionRepository subRepo;
    private final LeadRepository         leadRepo;
    private final S3Service              s3Service;
    private final SecurityUtil           securityUtil;
    private final PropertyServiceImpl    propertyService;

    @Override
    public AgentProfileResponse getPublicProfile(UUID agentId) {
        return toProfile(agentRepo.findById(agentId)
            .orElseThrow(() -> ApiException.notFound("Agent not found")));
    }

    @Override
    public AgentProfileResponse getMyProfile() {
        return toProfile(currentAgent());
    }

    @Override @Transactional
    public AgentProfileResponse updateMyProfile(AgentProfileRequest req) {
        Agent a = currentAgent();
        if (req.getCompanyName()    != null) a.setCompanyName(req.getCompanyName());
        if (req.getDescription()    != null) a.setDescription(req.getDescription());
        if (req.getWebsite()        != null) a.setWebsite(req.getWebsite());
        if (req.getCity()           != null) a.setCity(req.getCity());
        if (req.getState()          != null) a.setState(req.getState());
        if (req.getLicenseNo()      != null) a.setLicenseNo(req.getLicenseNo());
        if (req.getReraNo()         != null) a.setReraNo(req.getReraNo());
        return toProfile(agentRepo.save(a));
    }

    @Override @Transactional
    public AgentProfileResponse uploadLogo(MultipartFile logo) {
        Agent a = currentAgent();
        a.setLogoUrl(s3Service.uploadMedia(logo, "agents/" + a.getId() + "/logo"));
        return toProfile(agentRepo.save(a));
    }

    @Override
    public PagedResponse<PropertyResponse> getAgentProperties(UUID agentId, Pageable pageable) {
        Page<Property> page = propertyRepo.findByAgentIdOrderByCreatedAtDesc(agentId, pageable);
        return PagedResponse.<PropertyResponse>builder()
            .content(page.getContent().stream().map(propertyService::toResponse).collect(Collectors.toList()))
            .page(page.getNumber()).size(page.getSize())
            .totalElements(page.getTotalElements()).totalPages(page.getTotalPages())
            .last(page.isLast()).build();
    }

    @Override
    public DashboardStatsResponse getMyStats() {
        Agent a = currentAgent();
        UUID agentId = a.getId();
        long totalListings   = propertyRepo.countByAgentId(agentId);
        long activeListings  = propertyRepo.countActiveByAgent(agentId);
        long pendingListings = propertyRepo.countByAgentIdAndStatus(agentId, PropertyStatus.PENDING_REVIEW);
        long newLeads        = leadRepo.countByAgentIdAndStatus(agentId, LeadStatus.NEW);
        long leadsThisMonth  = leadRepo.countByAgentIdAndCreatedAtAfter(agentId,
            LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0));
        Subscription sub     = subRepo.findByAgentId(agentId).orElse(null);
        int maxListings      = sub != null ? sub.getPlan().getMaxListings() : 0;
        BigDecimal mrr       = sub != null && sub.getLastPaymentAmount() != null
            ? sub.getLastPaymentAmount() : BigDecimal.ZERO;
        return DashboardStatsResponse.builder()
            .totalAgents(1).verifiedAgents(a.isVerified() ? 1 : 0)
            .totalListings(totalListings).activeListings(activeListings).pendingListings(pendingListings)
            .leadsThisMonth(leadsThisMonth).mrr(mrr).basicPlanCount(maxListings)
            .build();
    }

    @Override
    public SubscriptionResponse getMySubscription() {
        Agent a = currentAgent();
        Subscription sub = subRepo.findByAgentId(a.getId())
            .orElseThrow(() -> ApiException.notFound("No subscription found"));
        long used = propertyRepo.countByAgentId(a.getId());
        int max   = sub.getPlan().getMaxListings();
        SubscriptionResponse r = new SubscriptionResponse();
        r.setId(sub.getId()); r.setStatus(sub.getStatus());
        r.setStartDate(sub.getStartDate()); r.setCurrentPeriodEnd(sub.getCurrentPeriodEnd());
        r.setAutoRenew(sub.isAutoRenew()); r.setYearly(sub.isYearly());
        r.setLastPaymentAmount(sub.getLastPaymentAmount()); r.setLastPaymentAt(sub.getLastPaymentAt());
        r.setPlanName(sub.getPlan().getName()); r.setPlanDisplayName(sub.getPlan().getDisplayName());
        r.setPriceMonthly(sub.getPlan().getPriceMonthly());
        r.setMaxListings(max); r.setMaxFeaturedListings(sub.getPlan().getMaxFeaturedListings());
        r.setVideoUpload(sub.getPlan().isVideoUpload()); r.setAnalyticsAccess(sub.getPlan().isAnalyticsAccess());
        r.setListingsUsed(used);
        r.setListingsRemaining(max == -1 ? Long.MAX_VALUE : Math.max(0, max - used));
        return r;
    }

    // ── Helpers ───────────────────────────────────────────────────

    private Agent currentAgent() {
        return agentRepo.findByUserId(securityUtil.getCurrentUserId())
            .orElseThrow(() -> ApiException.notFound("Agent profile not found"));
    }

    private AgentProfileResponse toProfile(Agent a) {
        AgentProfileResponse r = new AgentProfileResponse();
        r.setId(a.getId()); r.setCompanyName(a.getCompanyName());
        r.setDescription(a.getDescription()); r.setWebsite(a.getWebsite());
        r.setLogoUrl(a.getLogoUrl()); r.setCity(a.getCity()); r.setState(a.getState());
        r.setLicenseNo(a.getLicenseNo()); r.setReraNo(a.getReraNo());
        r.setVerified(a.isVerified()); r.setFeatured(a.isFeatured());
        r.setMemberSince(a.getCreatedAt());
        r.setTotalListings(propertyRepo.countByAgentId(a.getId()));
        r.setActiveListings(propertyRepo.countActiveByAgent(a.getId()));
        if (a.getUser() != null) {
            r.setOwnerName(a.getUser().getName());
            r.setEmail(a.getUser().getEmail());
            r.setPhone(a.getUser().getPhone());
        }
        if (a.getSubscription() != null)
            r.setSubscriptionPlan(a.getSubscription().getPlan().getDisplayName());
        return r;
    }
}
