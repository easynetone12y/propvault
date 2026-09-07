package com.propvault.dto.request;

import com.propvault.enums.LeadStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class LeadStatusUpdateRequest {
    @NotNull private LeadStatus status;
    private String notes;
    private LocalDateTime followUpAt;
    private LocalDateTime visitScheduledAt;
}
