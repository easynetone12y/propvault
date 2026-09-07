package com.propvault.dto.response;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class NotificationResponse {
    private UUID id;
    private String type;
    private String title;
    private String body;
    private String data;
    private boolean read;
    private LocalDateTime createdAt;
}
