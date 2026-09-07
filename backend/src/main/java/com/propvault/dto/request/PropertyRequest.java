package com.propvault.dto.request;

import com.propvault.enums.PropertyPurpose;
import com.propvault.enums.PropertyType;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class PropertyRequest {
    @NotBlank @Size(min = 10, max = 200)
    private String title;

    @NotBlank
    private String description;

    @NotNull private PropertyType type;
    @NotNull private PropertyPurpose purpose;

    @NotNull @DecimalMin("0.0")
    private BigDecimal price;

    @NotBlank private String address;
    @NotBlank private String locality;
    @NotBlank private String city;
    @NotBlank private String state;
    private String pincode;
    private Double latitude;
    private Double longitude;

    @Min(0) @Max(20) private Integer bedrooms;
    @Min(0) @Max(20) private Integer bathrooms;
    private Integer floor;
    private Integer totalFloors;

    @DecimalMin("0.0") private BigDecimal areaSqFt;
    @DecimalMin("0.0") private BigDecimal carpetAreaSqFt;
    private Integer buildYear;
    private String furnishingStatus;
    private String virtualTourUrl;
    private List<String> amenities;
}
