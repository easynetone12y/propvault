package com.propvault.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.UUID;

@Entity @Table(name = "property_analytics_daily",
    uniqueConstraints = @UniqueConstraint(columnNames = {"property_id","date"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PropertyAnalyticsDaily {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @Column(nullable = false) private LocalDate date;
    private int views;
    private int leads;
    private int whatsapp;
    private int calls;
}
