package com.propvault.service.impl;

import com.propvault.dto.response.*;
import com.propvault.entity.*;
import com.propvault.enums.*;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.service.AdminService;
import com.propvault.service.impl.PropertyServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Service @RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private final AgentRepository agentRepo;
    private final PropertyRepository propertyRepo;
    private final SubscriptionRepository subRepo;
    private final LeadRepository leadRepo;
    private final PropertyServiceImpl propertyService;

    @Override
    public DashboardStatsResponse getDashboardStats() {
        long totalAgents   = agentRepo.count();
        long verified      = agentRepo.countByVerified(true);
        long pending       = agentRepo.countByVerified(false);
        long totalList     = propertyRepo.count();
        long activeList    = propertyRepo.countByStatus(PropertyStatus.APPROVED);
        long pendingList   = propertyRepo.countByStatus(PropertyStatus.PENDING_REVIEW);
        long totalLeads    = leadRepo.count();
        long leadsThisMonth= leadRepo.countLeadsSince(LocalDateTime.now().withDayOfMonth(1));
        var mrr = subRepo.getTotalMRR();

        return DashboardStatsResponse.builder()
            .totalAgents(totalAgents).verifiedAgents(verified).pendingAgents(pending)
            .totalListings(totalList).activeListings(activeList).pendingListings(pendingList)
            .totalLeads(totalLeads).leadsThisMonth(leadsThisMonth).mrr(mrr)
            .basicPlanCount(subRepo.countByStatus(SubscriptionStatus.ACTIVE))
            .build();
    }

    @Override
    public Page<AgentResponse> getAllAgents(String status, Pageable pageable) {
        Boolean verified = status == null ? null : "verified".equalsIgnoreCase(status);
        return agentRepo.findWithFilters(verified, null, pageable).map(this::toAgentResponse);
    }

    @Override @Transactional
    public AgentResponse approveAgent(UUID agentId) {
        Agent agent = agentRepo.findById(agentId).orElseThrow(() -> ApiException.notFound("Agent not found"));
        agent.setVerified(true);
        return toAgentResponse(agentRepo.save(agent));
    }

    @Override @Transactional
    public void suspendAgent(UUID agentId, String reason) {
        Agent agent = agentRepo.findById(agentId).orElseThrow(() -> ApiException.notFound("Agent not found"));
        agent.getUser().setActive(false);
    }

    @Override
    public Page<PropertyResponse> getPendingProperties(Pageable pageable) {
        return propertyRepo.findByStatus(PropertyStatus.PENDING_REVIEW, pageable)
            .map(propertyService::toResponse);
    }

    @Override @Transactional
    public PropertyResponse approveProperty(UUID propertyId) {
        Property p = propertyRepo.findById(propertyId).orElseThrow(() -> ApiException.notFound("Property not found"));
        p.setStatus(PropertyStatus.APPROVED);
        p.setApprovedAt(LocalDateTime.now());
        return propertyService.toResponse(propertyRepo.save(p));
    }

    @Override @Transactional
    public void rejectProperty(UUID propertyId, String reason) {
        Property p = propertyRepo.findById(propertyId).orElseThrow(() -> ApiException.notFound("Property not found"));
        p.setStatus(PropertyStatus.REJECTED);
        p.setRejectionReason(reason);
        propertyRepo.save(p);
    }

    private AgentResponse toAgentResponse(Agent a) {
        AgentResponse r = new AgentResponse();
        r.setId(a.getId()); r.setCompanyName(a.getCompanyName());
        r.setLicenseNo(a.getLicenseNo()); r.setReraNo(a.getReraNo());
        r.setCity(a.getCity()); r.setState(a.getState());
        r.setLogoUrl(a.getLogoUrl()); r.setVerified(a.isVerified()); r.setFeatured(a.isFeatured());
        r.setCreatedAt(a.getCreatedAt());
        if (a.getUser() != null) {
            r.setUserId(a.getUser().getId()); r.setName(a.getUser().getName());
            r.setEmail(a.getUser().getEmail()); r.setPhone(a.getUser().getPhone());
        }
        if (a.getSubscription() != null) {
            r.setSubscriptionPlan(a.getSubscription().getPlan().getDisplayName());
            r.setSubscriptionStatus(a.getSubscription().getStatus().name());
        }
        r.setTotalListings(propertyRepo.countByAgentId(a.getId()));
        r.setActiveListings(propertyRepo.countActiveByAgent(a.getId()));
        return r;
    }
}
