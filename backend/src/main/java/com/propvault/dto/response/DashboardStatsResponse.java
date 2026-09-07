package com.propvault.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data @Builder
public class DashboardStatsResponse {
    private long totalAgents;
    private long verifiedAgents;
    private long pendingAgents;
    private long totalListings;
    private long activeListings;
    private long pendingListings;
    private long totalLeads;
    private long leadsThisMonth;
    private BigDecimal mrr;
    private long basicPlanCount;
    private long proPlanCount;
    private long premiumPlanCount;
}
