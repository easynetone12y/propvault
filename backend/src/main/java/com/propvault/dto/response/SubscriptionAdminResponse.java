package com.propvault.dto.response;
import com.propvault.enums.SubscriptionStatus;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data @Builder
public class SubscriptionAdminResponse {
    private UUID id;
    private UUID agentId;
    private String agentCompanyName;
    private String agentCity;
    private String planName;
    private String planDisplayName;
    private SubscriptionStatus status;
    private BigDecimal amount;
    private BigDecimal gstAmount;
    private LocalDate currentPeriodEnd;
    private String razorpaySubscriptionId;
}
