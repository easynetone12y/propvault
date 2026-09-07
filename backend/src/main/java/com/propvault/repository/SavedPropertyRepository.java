package com.propvault.repository;

import com.propvault.entity.SavedProperty;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SavedPropertyRepository
        extends JpaRepository<SavedProperty, SavedProperty.SavedPropertyId> {
    long countByBuyer_Id(UUID buyerId);
    Page<SavedProperty> findByBuyer_IdOrderByCreatedAtDesc(UUID buyerId, Pageable pageable);
    boolean existsByBuyer_IdAndProperty_Id(UUID buyerId, UUID propertyId);
    Optional<SavedProperty> findByBuyer_IdAndProperty_Id(UUID buyerId, UUID propertyId);
    long countByProperty_Id(UUID propertyId);
}
