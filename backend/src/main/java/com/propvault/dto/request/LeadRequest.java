package com.propvault.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class LeadRequest {
    @NotBlank @Size(min = 2, max = 80)
    private String customerName;

    @NotBlank @Pattern(regexp = "^[6-9]\\d{9}$")
    private String customerPhone;

    @Email private String customerEmail;

    @Size(max = 500)
    private String message;

    private String source; // FORM, WHATSAPP, CALL
}
