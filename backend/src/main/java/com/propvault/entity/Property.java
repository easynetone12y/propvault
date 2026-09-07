package com.propvault.entity;

import com.propvault.enums.PropertyPurpose;
import com.propvault.enums.PropertyStatus;
import com.propvault.enums.PropertyType;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "properties", indexes = {
    @Index(name = "idx_prop_agent",   columnList = "agent_id"),
    @Index(name = "idx_prop_status",  columnList = "status"),
    @Index(name = "idx_prop_city",    columnList = "city"),
    @Index(name = "idx_prop_type",    columnList = "type"),
    @Index(name = "idx_prop_purpose", columnList = "purpose"),
    @Index(name = "idx_prop_price",   columnList = "price"),
    @Index(name = "idx_prop_featured",columnList = "featured")
})
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Property {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agent agent;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private PropertyType type;

    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private PropertyPurpose purpose;

    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private PropertyStatus status;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    private String priceLabel;
    private String address;
    private String locality;

    @Column(nullable = false)
    private String city;

    @Column(nullable = false)
    private String state;

    private String pincode;
    private Double latitude;
    private Double longitude;
    private Integer bedrooms;
    private Integer bathrooms;
    private Integer floor;
    private Integer totalFloors;

    @Column(precision = 10, scale = 2)
    private BigDecimal areaSqFt;

    @Column(precision = 10, scale = 2)
    private BigDecimal carpetAreaSqFt;

    private Integer buildYear;
    private String furnishingStatus;
    private boolean featured = false;
    private boolean featuredHomepage = false;
    private String virtualTourUrl;

    @ElementCollection
    @CollectionTable(name = "property_amenities", joinColumns = @JoinColumn(name = "property_id"))
    @Column(name = "amenity")
    private List<String> amenities;

    @OneToMany(mappedBy = "property", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<PropertyMedia> media;

    @OneToMany(mappedBy = "property", cascade = CascadeType.ALL)
    private List<Lead> leads;

    private long viewCount = 0;
    private long contactCount = 0;
    private String rejectionReason;
    private LocalDateTime approvedAt;

    @CreatedDate @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
