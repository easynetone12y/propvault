package com.propvault.dto.response;

import com.propvault.enums.PropertyPurpose;
import com.propvault.enums.PropertyStatus;
import com.propvault.enums.PropertyType;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
public class PropertyResponse {
    private UUID id;
    private String title;
    private String description;
    private PropertyType type;
    private PropertyPurpose purpose;
    private PropertyStatus status;
    private BigDecimal price;
    private String priceLabel;
    private String address;
    private String locality;
    private String city;
    private String state;
    private String pincode;
    private Double latitude;
    private Double longitude;
    private Integer bedrooms;
    private Integer bathrooms;
    private BigDecimal areaSqFt;
    private String furnishingStatus;
    private boolean featured;
    private String virtualTourUrl;
    private List<String> amenities;
    private List<MediaResponse> media;
    private AgentSummaryResponse agent;
    private long viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
