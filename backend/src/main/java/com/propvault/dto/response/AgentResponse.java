package com.propvault.dto.response;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class AgentResponse {
    private UUID id;
    private UUID userId;
    private String companyName;
    private String name;
    private String email;
    private String phone;
    private String licenseNo;
    private String reraNo;
    private String city;
    private String state;
    private String logoUrl;
    private boolean verified;
    private boolean featured;
    private String subscriptionPlan;
    private String subscriptionStatus;
    private long totalListings;
    private long activeListings;
    private LocalDateTime createdAt;
}
