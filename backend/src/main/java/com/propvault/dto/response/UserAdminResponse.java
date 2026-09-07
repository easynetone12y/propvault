package com.propvault.dto.response;
import com.propvault.enums.UserRole;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Data @Builder
public class UserAdminResponse {
    private UUID id;
    private String name;
    private String email;
    private String phone;
    private UserRole role;
    private boolean active;
    private boolean emailVerified;
    private long savedCount;
    private long leadsSubmitted;
    private LocalDateTime joinedAt;
}
