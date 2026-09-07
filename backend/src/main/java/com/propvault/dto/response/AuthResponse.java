package com.propvault.dto.response;

import com.propvault.enums.UserRole;
import lombok.Builder;
import lombok.Data;
import java.util.UUID;

@Data @Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private long expiresIn;
    private UUID userId;
    private String name;
    private String email;
    private UserRole role;
    private UUID agentId; // null for buyers
}
