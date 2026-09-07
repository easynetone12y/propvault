package com.propvault.dto.response;

import com.propvault.enums.LeadStatus;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class LeadResponse {
    private UUID id;
    private UUID propertyId;
    private String propertyTitle;
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private LeadStatus status;
    private String message;
    private String source;
    private String notes;
    private LocalDateTime followUpAt;
    private LocalDateTime visitScheduledAt;
    private LocalDateTime closedAt;
    private LocalDateTime createdAt;
}
