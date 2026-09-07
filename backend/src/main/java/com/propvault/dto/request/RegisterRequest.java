package com.propvault.dto.request;

import com.propvault.enums.UserRole;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank @Size(min = 2, max = 80)
    private String name;

    @NotBlank @Email
    private String email;

    @NotBlank @Size(min = 8, max = 64)
    private String password;

    @Pattern(regexp = "^[6-9]\\d{9}$", message = "Enter valid 10-digit Indian mobile number")
    private String phone;

    @NotNull
    private UserRole role; // AGENT or BUYER

    // Agent-only fields
    private String companyName;
    private String licenseNo;
    private String reraNo;
    private String city;
    private String state;
}
