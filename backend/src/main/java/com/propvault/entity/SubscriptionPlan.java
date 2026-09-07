package com.propvault.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "subscription_plans")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SubscriptionPlan {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false)
    private String displayName;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal priceMonthly;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal priceYearly;

    @Column(nullable = false)
    private Integer maxListings; // -1 = unlimited

    private Integer maxFeaturedListings;
    private Integer maxImages;
    private boolean videoUpload;
    private boolean analyticsAccess;
    private boolean priorityLeads;
    private boolean verifiedBadge;
    private boolean aiDescriptions;
    private boolean whatsappIntegration;
    private String razorpayPlanIdMonthly;
    private String razorpayPlanIdYearly;
    private boolean active = true;
    private int sortOrder;
}
