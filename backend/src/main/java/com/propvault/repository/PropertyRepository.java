package com.propvault.repository;

import com.propvault.entity.Property;
import com.propvault.enums.PropertyPurpose;
import com.propvault.enums.PropertyStatus;
import com.propvault.enums.PropertyType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface PropertyRepository extends JpaRepository<Property, UUID>,
        JpaSpecificationExecutor<Property> {

    Page<Property> findByAgentIdOrderByCreatedAtDesc(UUID agentId, Pageable pageable);
    Page<Property> findByStatus(PropertyStatus status, Pageable pageable);
    long countByStatus(PropertyStatus status);
    long countByAgentId(UUID agentId);
    long countByAgentIdAndStatus(UUID agentId, PropertyStatus status);

    @Modifying
    @Query("UPDATE Property p SET p.viewCount = p.viewCount + 1 WHERE p.id = :id")
    void incrementViewCount(UUID id);

    @Query("SELECT COUNT(p) FROM Property p WHERE p.agent.id = :agentId AND p.status = 'APPROVED'")
    long countActiveByAgent(UUID agentId);
}
