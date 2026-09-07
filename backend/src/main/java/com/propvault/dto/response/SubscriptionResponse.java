package com.propvault.dto.response;

import com.propvault.enums.SubscriptionStatus;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class SubscriptionResponse {
    private UUID id;
    private String planName;
    private String planDisplayName;
    private SubscriptionStatus status;
    private BigDecimal priceMonthly;
    private Integer maxListings;
    private Integer maxFeaturedListings;
    private boolean videoUpload;
    private boolean analyticsAccess;
    private LocalDate startDate;
    private LocalDate currentPeriodEnd;
    private boolean autoRenew;
    private boolean yearly;
    private BigDecimal lastPaymentAmount;
    private LocalDateTime lastPaymentAt;
    private long listingsUsed;
    private long listingsRemaining;
}
