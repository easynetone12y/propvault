package com.propvault.controller;

import com.propvault.dto.request.VisitRequestDto;
import com.propvault.dto.response.VisitResponse;
import com.propvault.service.VisitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.UUID;

@RestController @RequestMapping("/visits") @RequiredArgsConstructor
@Tag(name = "Visits", description = "Property site visit scheduling")
public class VisitController {
    private final VisitService visitService;

    @PostMapping("/property/{propertyId}")
    @Operation(summary = "Request a site visit — guest and authenticated buyers both supported")
    public ResponseEntity<VisitResponse> requestVisit(
            @PathVariable UUID propertyId,
            @Valid @RequestBody VisitRequestDto req) {
        return ResponseEntity.ok(visitService.requestVisit(propertyId, req));
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Page<VisitResponse>> getAgentVisits(
            @RequestParam(required = false) String status,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(visitService.getAgentVisits(status, pageable));
    }

    @GetMapping("/buyer")
    @PreAuthorize("hasRole('BUYER')")
    public ResponseEntity<Page<VisitResponse>> getBuyerVisits(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(visitService.getBuyerVisits(pageable));
    }

    @PatchMapping("/{id}/confirm")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<VisitResponse> confirmVisit(
            @PathVariable UUID id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime confirmedAt,
            @RequestParam(required = false) String notes) {
        return ResponseEntity.ok(visitService.confirmVisit(id, confirmedAt, notes));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<VisitResponse> updateStatus(
            @PathVariable UUID id,
            @RequestParam String status,
            @RequestParam(required = false) String notes) {
        return ResponseEntity.ok(visitService.updateStatus(id, status, notes));
    }
}
