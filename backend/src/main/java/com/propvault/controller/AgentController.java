package com.propvault.controller;

import com.propvault.dto.request.AgentProfileRequest;
import com.propvault.dto.response.*;
import com.propvault.service.AgentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.UUID;

@RestController @RequestMapping("/agents") @RequiredArgsConstructor
@Tag(name = "Agents", description = "Agent profile — public and self-management")
public class AgentController {
    private final AgentService agentService;

    @GetMapping("/{id}/public")
    @Operation(summary = "Public agent profile with listing count and credentials")
    public ResponseEntity<AgentProfileResponse> getPublicProfile(@PathVariable UUID id) {
        return ResponseEntity.ok(agentService.getPublicProfile(id));
    }

    @GetMapping("/{id}/properties")
    @Operation(summary = "All live listings by a specific agent")
    public ResponseEntity<PagedResponse<PropertyResponse>> getAgentProperties(
            @PathVariable UUID id,
            @PageableDefault(size = 12) Pageable pageable) {
        return ResponseEntity.ok(agentService.getAgentProperties(id, pageable));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<AgentProfileResponse> getMyProfile() {
        return ResponseEntity.ok(agentService.getMyProfile());
    }

    @PutMapping("/me")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<AgentProfileResponse> updateMyProfile(
            @Valid @RequestBody AgentProfileRequest req) {
        return ResponseEntity.ok(agentService.updateMyProfile(req));
    }

    @PostMapping(value = "/me/logo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Upload company logo to S3")
    public ResponseEntity<AgentProfileResponse> uploadLogo(@RequestPart MultipartFile logo) {
        return ResponseEntity.ok(agentService.uploadLogo(logo));
    }

    @GetMapping("/me/stats")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<DashboardStatsResponse> getMyStats() {
        return ResponseEntity.ok(agentService.getMyStats());
    }

    @GetMapping("/me/subscription")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<SubscriptionResponse> getMySubscription() {
        return ResponseEntity.ok(agentService.getMySubscription());
    }
}
