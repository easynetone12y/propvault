package com.propvault.controller;

import com.propvault.dto.request.*;
import com.propvault.dto.response.LeadResponse;
import com.propvault.enums.LeadStatus;
import com.propvault.service.LeadService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController @RequestMapping("/leads") @RequiredArgsConstructor
public class LeadController {
    private final LeadService leadService;

    @PostMapping("/property/{propertyId}")
    public ResponseEntity<LeadResponse> submit(@PathVariable UUID propertyId,
            @Valid @RequestBody LeadRequest req) {
        return ResponseEntity.ok(leadService.submit(propertyId, req));
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Page<LeadResponse>> getMyLeads(
            @RequestParam(required=false) LeadStatus status,
            @PageableDefault(size=20) Pageable pageable) {
        return ResponseEntity.ok(leadService.getAgentLeads(status, pageable));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<LeadResponse> updateStatus(@PathVariable UUID id,
            @Valid @RequestBody LeadStatusUpdateRequest req) {
        return ResponseEntity.ok(leadService.updateStatus(id, req));
    }
}
