package com.propvault.dto.response;
import lombok.Data;
import java.time.*;
import java.util.UUID;

@Data
public class VisitResponse {
    private UUID id;
    private UUID propertyId;
    private String propertyTitle;
    private String propertyCity;
    private String buyerName;
    private String buyerPhone;
    private String buyerEmail;
    private LocalDate preferredDate;
    private String preferredTimeSlot;
    private LocalDateTime confirmedDatetime;
    private String status;
    private String agentNotes;
    private String buyerNotes;
    private LocalDateTime createdAt;
}
