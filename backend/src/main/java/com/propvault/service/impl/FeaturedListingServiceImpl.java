package com.propvault.service.impl;

import com.propvault.dto.response.PropertyResponse;
import com.propvault.entity.*;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.service.FeaturedListingService;
import com.propvault.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service @RequiredArgsConstructor
public class FeaturedListingServiceImpl implements FeaturedListingService {

    private final PropertyRepository     propertyRepo;
    private final SubscriptionRepository subRepo;
    private final SecurityUtil           securityUtil;
    private final PropertyServiceImpl    propertyService;

    @Override @Transactional
    public PropertyResponse toggleFeatured(UUID propertyId, boolean featured) {
        UUID agentId = securityUtil.getCurrentAgentId();
        Property property = propertyRepo.findById(propertyId)
            .orElseThrow(() -> ApiException.notFound("Property not found"));
        if (!property.getAgent().getId().equals(agentId))
            throw ApiException.forbidden("You do not own this property");
        if (featured) {
            Subscription sub = subRepo.findByAgentId(agentId)
                .orElseThrow(() -> ApiException.badRequest("No active subscription"));
            int max = sub.getPlan().getMaxFeaturedListings() != null
                ? sub.getPlan().getMaxFeaturedListings() : 0;
            if (max != -1) {
                long used = propertyRepo.countByAgentIdAndFeatured(agentId, true);
                if (used >= max)
                    throw ApiException.badRequest(
                        "Featured slot limit reached (" + max + "). Upgrade your plan.");
            }
        }
        property.setFeatured(featured);
        return propertyService.toResponse(propertyRepo.save(property));
    }

    @Override
    public int getRemainingFeaturedSlots() {
        UUID agentId = securityUtil.getCurrentAgentId();
        Subscription sub = subRepo.findByAgentId(agentId).orElse(null);
        if (sub == null) return 0;
        int max = sub.getPlan().getMaxFeaturedListings() != null
            ? sub.getPlan().getMaxFeaturedListings() : 0;
        if (max == -1) return Integer.MAX_VALUE;
        long used = propertyRepo.countByAgentIdAndFeatured(agentId, true);
        return (int) Math.max(0, max - used);
    }
}
