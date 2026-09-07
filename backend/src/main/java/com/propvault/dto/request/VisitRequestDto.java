package com.propvault.dto.request;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

// Named VisitRequestDto to avoid clash with entity VisitRequest
@Data
public class VisitRequestDto {
    @NotBlank @Size(min=2, max=80) private String buyerName;
    @NotBlank @Pattern(regexp="^[6-9]\\d{9}$") private String buyerPhone;
    private String buyerEmail;
    @NotNull @Future private LocalDate preferredDate;
    @NotBlank private String preferredTimeSlot; // MORNING | AFTERNOON | EVENING
    @Size(max=500) private String buyerNotes;
}
