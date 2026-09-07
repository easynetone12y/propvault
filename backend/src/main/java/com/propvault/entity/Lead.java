package com.propvault.entity;

import com.propvault.enums.LeadStatus;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "leads", indexes = {
    @Index(name = "idx_lead_agent",   columnList = "agent_id"),
    @Index(name = "idx_lead_status",  columnList = "status"),
    @Index(name = "idx_lead_created", columnList = "created_at")
})
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Lead {
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
    private User buyer;

    private String customerName;
    private String customerPhone;
    private String customerEmail;

    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private LeadStatus status;

    private String message;
    private String source; // FORM, WHATSAPP, CALL
    private String notes;
    private LocalDateTime followUpAt;
    private LocalDateTime visitScheduledAt;
    private LocalDateTime closedAt;

    @CreatedDate @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
