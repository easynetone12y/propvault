package com.propvault.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "visit_requests")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class VisitRequest {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agent agent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_user_id")
    private User buyer; // null for guest visits

    @Column(nullable = false) private String buyerName;
    @Column(nullable = false) private String buyerPhone;
    private String buyerEmail;
    @Column(nullable = false) private LocalDate preferredDate;
    @Column(nullable = false) private String preferredTimeSlot; // MORNING | AFTERNOON | EVENING
    private LocalDateTime confirmedDatetime;
    @Column(nullable = false) private String status; // REQUESTED|CONFIRMED|CANCELLED|COMPLETED|NO_SHOW
    private String agentNotes;
    private String buyerNotes;

    @CreatedDate @Column(updatable = false) private LocalDateTime createdAt;
    @LastModifiedDate private LocalDateTime updatedAt;
}
