package com.propvault.dto.request;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class AgentProfileRequest {
    @Size(max=200) private String companyName;
    @Size(max=200) private String tagline;
    @Size(max=2000) private String description;
    @Size(max=300) private String website;
    @Min(0) @Max(60) private Integer yearsExperience;
    private String specializations; // CSV: "Residential,Commercial"
    private String languages;       // CSV: "Hindi,English"
    private String city;
    private String state;
    private String licenseNo;
    private String reraNo;
    private String facebookUrl;
    private String linkedinUrl;
    private String instagramUrl;
}
