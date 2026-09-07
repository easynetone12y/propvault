package com.propvault.repository;

import com.propvault.entity.Lead;
import com.propvault.enums.LeadStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.UUID;

@Repository
public interface LeadRepository extends JpaRepository<Lead, UUID> {
    Page<Lead> findByAgentIdOrderByCreatedAtDesc(UUID agentId, Pageable pageable);
    Page<Lead> findByAgentIdAndStatusOrderByCreatedAtDesc(UUID agentId, LeadStatus status, Pageable pageable);
    long countByAgentIdAndStatus(UUID agentId, LeadStatus status);
    long countByAgentIdAndCreatedAtAfter(UUID agentId, LocalDateTime after);

    @Query("SELECT COUNT(l) FROM Lead l WHERE l.createdAt >= :from")
    long countLeadsSince(LocalDateTime from);
}
