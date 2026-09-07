package com.propvault.repository;

import com.propvault.entity.Agent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AgentRepository extends JpaRepository<Agent, UUID> {
    Optional<Agent> findByUserId(UUID userId);
    Page<Agent> findByVerified(boolean verified, Pageable pageable);

    @Query("SELECT a FROM Agent a WHERE " +
           "(:verified IS NULL OR a.verified = :verified) AND " +
           "(:city IS NULL OR LOWER(a.city) = LOWER(:city))")
    Page<Agent> findWithFilters(Boolean verified, String city, Pageable pageable);

    long countByVerified(boolean verified);
}
