package com.propvault.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "saved_properties")
@IdClass(SavedProperty.SavedPropertyId.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SavedProperty {
    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_user_id", nullable = false)
    private User buyer;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @Data @NoArgsConstructor @AllArgsConstructor
    public static class SavedPropertyId implements Serializable {
        private UUID buyer;
        private UUID property;
    }
}
