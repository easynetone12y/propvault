package com.propvault.dto.response;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class AgentProfileResponse {
    private UUID id;
    private String companyName;
    private String ownerName;
    private String email;
    private String phone;
    private String tagline;
    private String description;
    private String website;
    private String logoUrl;
    private String city;
    private String state;
    private String licenseNo;
    private String reraNo;
    private Integer yearsExperience;
    private String specializations;
    private String languages;
    private String facebookUrl;
    private String linkedinUrl;
    private String instagramUrl;
    private boolean verified;
    private boolean featured;
    private long totalListings;
    private long activeListings;
    private long profileViews;
    private String subscriptionPlan;
    private LocalDateTime memberSince;
}
