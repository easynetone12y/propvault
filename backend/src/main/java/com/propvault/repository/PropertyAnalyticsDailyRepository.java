package com.propvault.repository;

import com.propvault.entity.PropertyAnalyticsDaily;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.*;

@Repository
public interface PropertyAnalyticsDailyRepository extends JpaRepository<PropertyAnalyticsDaily, UUID> {
    List<PropertyAnalyticsDaily> findByPropertyIdAndDateBetweenOrderByDateAsc(
        UUID propertyId, LocalDate from, LocalDate to);

    @Query("SELECT a.date, SUM(a.views), SUM(a.leads), SUM(a.whatsapp), SUM(a.calls) " +
           "FROM PropertyAnalyticsDaily a WHERE a.property.agent.id = :agentId " +
           "AND a.date BETWEEN :from AND :to GROUP BY a.date ORDER BY a.date ASC")
    List<Object[]> getAgentDailyStats(UUID agentId, LocalDate from, LocalDate to);
}
