package com.propvault.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.UUID;

@Data
public class SubscribeRequest {
    @NotNull  private UUID planId;
    @NotNull  private boolean yearly;
}
