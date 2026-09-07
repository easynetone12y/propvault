package com.propvault.controller;

import com.propvault.dto.response.AnalyticsResponse;
import com.propvault.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController @RequestMapping("/analytics") @RequiredArgsConstructor
@Tag(name = "Analytics", description = "Agent engagement analytics")
public class AnalyticsController {
    private final AnalyticsService analyticsService;

    @GetMapping("/agent/me")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "30-day aggregate analytics for the logged-in agent")
    public ResponseEntity<AnalyticsResponse> getMyAnalytics(
            @RequestParam(defaultValue = "30") int days) {
        return ResponseEntity.ok(analyticsService.getAgentAnalytics(days));
    }

    @GetMapping("/agent/me/property/{propertyId}")
    @PreAuthorize("hasRole('AGENT')")
    @Operation(summary = "Per-property analytics for the logged-in agent")
    public ResponseEntity<AnalyticsResponse> getPropertyAnalytics(
            @PathVariable UUID propertyId,
            @RequestParam(defaultValue = "30") int days) {
        return ResponseEntity.ok(analyticsService.getPropertyAnalytics(propertyId, days));
    }
}
