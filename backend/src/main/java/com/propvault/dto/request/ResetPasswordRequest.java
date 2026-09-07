package com.propvault.dto.request;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ResetPasswordRequest {
    @NotBlank private String token;
    @NotBlank @Size(min=8, max=64) private String newPassword;
}
