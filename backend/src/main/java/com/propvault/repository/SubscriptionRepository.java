package com.propvault.repository;

import com.propvault.entity.Subscription;
import com.propvault.enums.SubscriptionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, UUID> {
    Optional<Subscription> findByAgentId(UUID agentId);
    Optional<Subscription> findByRazorpaySubscriptionId(String razorpaySubId);
    List<Subscription> findByStatusAndCurrentPeriodEndBefore(SubscriptionStatus status, LocalDate date);

    @Query("SELECT COUNT(s) FROM Subscription s WHERE s.status = :status")
    long countByStatus(SubscriptionStatus status);

    @Query("SELECT SUM(s.lastPaymentAmount) FROM Subscription s WHERE s.status = 'ACTIVE'")
    java.math.BigDecimal getTotalMRR();
}
