package com.propvault.service;

import com.propvault.dto.response.AnalyticsResponse;
import java.util.UUID;

public interface AnalyticsService {
    AnalyticsResponse getAgentAnalytics(int days);
    AnalyticsResponse getPropertyAnalytics(UUID propertyId, int days);
    /** Scheduled nightly at 23:55 IST to snapshot daily metrics */
    void snapshotDailyMetrics();
}
