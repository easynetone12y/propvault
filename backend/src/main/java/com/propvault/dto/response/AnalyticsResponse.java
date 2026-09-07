package com.propvault.dto.response;
import lombok.*;
import java.util.List;

@Data @Builder
public class AnalyticsResponse {
    private long totalViews;
    private long totalLeads;
    private long totalWhatsapp;
    private long totalCalls;
    private long totalListings;
    private long activeListings;
    private double leadConversionRate;
    private List<DailyStat> dailyStats;
    private List<PropertyStat> topProperties;

    @Data @Builder
    public static class DailyStat {
        private String date;
        private int views;
        private int leads;
        private int whatsapp;
        private int calls;
    }

    @Data @Builder
    public static class PropertyStat {
        private String propertyId;
        private String title;
        private long views;
        private long leads;
    }
}
