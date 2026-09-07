package com.propvault.service.impl;

import com.propvault.dto.response.AnalyticsResponse;
import com.propvault.entity.Property;
import com.propvault.enums.LeadStatus;
import com.propvault.repository.*;
import com.propvault.service.AnalyticsService;
import com.propvault.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor @Slf4j
public class AnalyticsServiceImpl implements AnalyticsService {

    private final PropertyRepository             propertyRepo;
    private final PropertyAnalyticsDailyRepository analyticsRepo;
    private final LeadRepository                 leadRepo;
    private final SecurityUtil                   securityUtil;

    @Override
    public AnalyticsResponse getAgentAnalytics(int days) {
        UUID agentId = securityUtil.getCurrentAgentId();
        LocalDate from = LocalDate.now().minusDays(days);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM dd");

        List<Object[]> raw = analyticsRepo.getAgentDailyStats(agentId, from, LocalDate.now());
        List<AnalyticsResponse.DailyStat> daily = raw.stream().map(r ->
            AnalyticsResponse.DailyStat.builder()
                .date(((LocalDate) r[0]).format(fmt))
                .views(r[1]  != null ? ((Number) r[1]).intValue()  : 0)
                .leads(r[2]  != null ? ((Number) r[2]).intValue()  : 0)
                .whatsapp(r[3] != null ? ((Number) r[3]).intValue() : 0)
                .calls(r[4]  != null ? ((Number) r[4]).intValue()  : 0)
                .build()
        ).collect(Collectors.toList());

        long totalViews    = daily.stream().mapToLong(AnalyticsResponse.DailyStat::getViews).sum();
        long totalLeads    = daily.stream().mapToLong(AnalyticsResponse.DailyStat::getLeads).sum();
        long totalWhatsapp = daily.stream().mapToLong(AnalyticsResponse.DailyStat::getWhatsapp).sum();
        long totalCalls    = daily.stream().mapToLong(AnalyticsResponse.DailyStat::getCalls).sum();

        List<AnalyticsResponse.PropertyStat> topProperties =
            propertyRepo.findByAgentIdOrderByCreatedAtDesc(agentId, PageRequest.of(0, 5))
                .getContent().stream().map(p ->
                    AnalyticsResponse.PropertyStat.builder()
                        .propertyId(p.getId().toString())
                        .title(p.getTitle())
                        .views(p.getViewCount())
                        .leads(leadRepo.countByAgentIdAndStatus(agentId, LeadStatus.NEW))
                        .build())
                .collect(Collectors.toList());

        return AnalyticsResponse.builder()
            .totalViews(totalViews).totalLeads(totalLeads)
            .totalWhatsapp(totalWhatsapp).totalCalls(totalCalls)
            .totalListings(propertyRepo.countByAgentId(agentId))
            .activeListings(propertyRepo.countActiveByAgent(agentId))
            .leadConversionRate(totalViews > 0 ? (double) totalLeads / totalViews * 100 : 0)
            .dailyStats(daily).topProperties(topProperties)
            .build();
    }

    @Override
    public AnalyticsResponse getPropertyAnalytics(UUID propertyId, int days) {
        LocalDate from = LocalDate.now().minusDays(days);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM dd");

        List<AnalyticsResponse.DailyStat> daily =
            analyticsRepo.findByPropertyIdAndDateBetweenOrderByDateAsc(propertyId, from, LocalDate.now())
                .stream().map(a -> AnalyticsResponse.DailyStat.builder()
                    .date(a.getDate().format(fmt))
                    .views(a.getViews()).leads(a.getLeads())
                    .whatsapp(a.getWhatsapp()).calls(a.getCalls())
                    .build())
                .collect(Collectors.toList());

        long totalViews = daily.stream().mapToLong(AnalyticsResponse.DailyStat::getViews).sum();
        long totalLeads = daily.stream().mapToLong(AnalyticsResponse.DailyStat::getLeads).sum();

        return AnalyticsResponse.builder()
            .totalViews(totalViews).totalLeads(totalLeads)
            .dailyStats(daily).build();
    }

    /**
     * Runs nightly at 23:55 IST.
     * In production: iterate all active properties and upsert daily metric rows.
     */
    @Override
    @Scheduled(cron = "0 55 23 * * *", zone = "Asia/Kolkata")
    public void snapshotDailyMetrics() {
        log.info("Daily analytics snapshot triggered — implement batch upsert here");
    }
}
