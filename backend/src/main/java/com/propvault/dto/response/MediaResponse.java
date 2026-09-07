package com.propvault.dto.response;

import com.propvault.enums.MediaType;
import lombok.Data;
import java.util.UUID;

@Data
public class MediaResponse {
    private UUID id;
    private MediaType mediaType;
    private String mediaUrl;
    private String thumbnailUrl;
    private boolean primary;
    private int sortOrder;
}
