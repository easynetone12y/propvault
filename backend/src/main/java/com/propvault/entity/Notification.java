package com.propvault.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "notifications")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false) private String type;  // NEW_LEAD | VISIT_REQUEST | LISTING_APPROVED …
    @Column(nullable = false) private String title;
    @Column(nullable = false) private String body;
    private String data; // JSON payload: propertyId, leadId, etc.
    private boolean read = false;

    @CreatedDate @Column(updatable = false) private LocalDateTime createdAt;
}
