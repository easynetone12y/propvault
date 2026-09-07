package com.propvault.service.impl;

import com.propvault.dto.request.*;
import com.propvault.dto.response.LeadResponse;
import com.propvault.entity.*;
import com.propvault.enums.LeadStatus;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.service.LeadService;
import com.propvault.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.UUID;

@Service @RequiredArgsConstructor
public class LeadServiceImpl implements LeadService {

    private final LeadRepository leadRepo;
    private final PropertyRepository propertyRepo;
    private final AgentRepository agentRepo;
    private final SecurityUtil securityUtil;

    @Override @Transactional
    public LeadResponse submit(UUID propertyId, LeadRequest req) {
        Property property = propertyRepo.findById(propertyId)
            .orElseThrow(() -> ApiException.notFound("Property not found"));
        Lead lead = Lead.builder()
            .property(property).agent(property.getAgent())
            .customerName(req.getCustomerName()).customerPhone(req.getCustomerPhone())
            .customerEmail(req.getCustomerEmail()).message(req.getMessage())
            .source(req.getSource() != null ? req.getSource() : "FORM")
            .status(LeadStatus.NEW).build();
        return toResponse(leadRepo.save(lead));
    }

    @Override
    public Page<LeadResponse> getAgentLeads(LeadStatus status, Pageable pageable) {
        UUID agentId = securityUtil.getCurrentAgentId();
        Page<Lead> page = status != null
            ? leadRepo.findByAgentIdAndStatusOrderByCreatedAtDesc(agentId, status, pageable)
            : leadRepo.findByAgentIdOrderByCreatedAtDesc(agentId, pageable);
        return page.map(this::toResponse);
    }

    @Override @Transactional
    public LeadResponse updateStatus(UUID id, LeadStatusUpdateRequest req) {
        Lead lead = leadRepo.findById(id).orElseThrow(() -> ApiException.notFound("Lead not found"));
        if (!lead.getAgent().getId().equals(securityUtil.getCurrentAgentId()))
            throw ApiException.forbidden("Not your lead");
        lead.setStatus(req.getStatus());
        if (req.getNotes() != null) lead.setNotes(req.getNotes());
        if (req.getFollowUpAt() != null) lead.setFollowUpAt(req.getFollowUpAt());
        if (req.getVisitScheduledAt() != null) lead.setVisitScheduledAt(req.getVisitScheduledAt());
        if (req.getStatus() == LeadStatus.CLOSED_WON || req.getStatus() == LeadStatus.CLOSED_LOST)
            lead.setClosedAt(LocalDateTime.now());
        return toResponse(leadRepo.save(lead));
    }

    private LeadResponse toResponse(Lead l) {
        LeadResponse r = new LeadResponse();
        r.setId(l.getId()); r.setStatus(l.getStatus()); r.setMessage(l.getMessage());
        r.setSource(l.getSource()); r.setNotes(l.getNotes());
        r.setCustomerName(l.getCustomerName()); r.setCustomerPhone(l.getCustomerPhone());
        r.setCustomerEmail(l.getCustomerEmail());
        r.setFollowUpAt(l.getFollowUpAt()); r.setVisitScheduledAt(l.getVisitScheduledAt());
        r.setClosedAt(l.getClosedAt()); r.setCreatedAt(l.getCreatedAt());
        if (l.getProperty() != null) {
            r.setPropertyId(l.getProperty().getId());
            r.setPropertyTitle(l.getProperty().getTitle());
        }
        return r;
    }
}
