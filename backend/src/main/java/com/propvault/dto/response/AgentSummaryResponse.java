package com.propvault.dto.response;

import lombok.Data;
import java.util.UUID;

@Data
public class AgentSummaryResponse {
    private UUID id;
    private String companyName;
    private String name;
    private String phone;
    private String logoUrl;
    private String city;
    private boolean verified;
    private long totalListings;
}
