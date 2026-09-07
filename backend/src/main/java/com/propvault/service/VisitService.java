package com.propvault.service;

import com.propvault.dto.request.VisitRequestDto;
import com.propvault.dto.response.VisitResponse;
import org.springframework.data.domain.*;
import java.time.LocalDateTime;
import java.util.UUID;

public interface VisitService {
    VisitResponse requestVisit(UUID propertyId, VisitRequestDto request);
    Page<VisitResponse> getAgentVisits(String status, Pageable pageable);
    Page<VisitResponse> getBuyerVisits(Pageable pageable);
    VisitResponse confirmVisit(UUID visitId, LocalDateTime confirmedAt, String notes);
    VisitResponse updateStatus(UUID visitId, String status, String notes);
}
