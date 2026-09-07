package com.propvault.entity;

import com.propvault.enums.MediaType;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "property_media")
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PropertyMedia {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private MediaType mediaType;

    @Column(nullable = false)
    private String mediaUrl;

    private String thumbnailUrl;
    private String s3Key;
    private Long fileSizeBytes;
    private String mimeType;
    private boolean primary = false;
    private int sortOrder;

    @CreatedDate @Column(updatable = false)
    private LocalDateTime createdAt;
}
