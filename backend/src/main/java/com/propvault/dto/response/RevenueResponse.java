package com.propvault.dto.response;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Data @Builder
public class RevenueResponse {
    private BigDecimal totalMrr;
    private BigDecimal totalGst;
    private List<PlanRevenue> byPlan;

    @Data @Builder
    public static class PlanRevenue {
        private String planName;
        private String planDisplayName;
        private long activeAgentCount;
        private BigDecimal mrr;
    }
}
