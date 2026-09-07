package com.propvault.service;

import com.propvault.dto.response.PropertyResponse;
import java.util.UUID;

/** Manages agent featured-slot quota enforcement per subscription plan. */
public interface FeaturedListingService {
    PropertyResponse toggleFeatured(UUID propertyId, boolean featured);
    int getRemainingFeaturedSlots();
}
