package com.propvault.repository;

import com.propvault.entity.VisitRequest;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.*;

@Repository
public interface VisitRequestRepository extends JpaRepository<VisitRequest, UUID> {
    Page<VisitRequest> findByAgent_IdOrderByPreferredDateAsc(UUID agentId, Pageable pageable);
    Page<VisitRequest> findByAgent_IdAndStatusOrderByPreferredDateAsc(UUID agentId, String status, Pageable pageable);
    List<VisitRequest> findByAgent_IdAndPreferredDateAndStatus(UUID agentId, LocalDate date, String status);
    long countByAgent_IdAndStatus(UUID agentId, String status);
    Page<VisitRequest> findByBuyer_IdOrderByCreatedAtDesc(UUID buyerUserId, Pageable pageable);
}
