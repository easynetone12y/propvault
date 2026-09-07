package com.propvault.repository;

import com.propvault.entity.Invoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, UUID> {
    Page<Invoice> findByAgentIdOrderByCreatedAtDesc(UUID agentId, Pageable pageable);

    @Query("SELECT MAX(CAST(SUBSTRING(i.invoiceNumber, 10) AS int)) FROM Invoice i")
    Optional<Integer> findMaxInvoiceNumber();
}
