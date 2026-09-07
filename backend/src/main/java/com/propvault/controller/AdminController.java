package com.propvault.controller;

import com.propvault.dto.response.*;
import com.propvault.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController @RequestMapping("/admin") @RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class AdminController {
    private final AdminService adminService;

    @GetMapping("/dashboard")
    public ResponseEntity<DashboardStatsResponse> dashboard() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }

    @GetMapping("/agents")
    public ResponseEntity<Page<AgentResponse>> agents(
            @RequestParam(required=false) String status, Pageable pageable) {
        return ResponseEntity.ok(adminService.getAllAgents(status, pageable));
    }

    @PatchMapping("/agents/{id}/approve")
    public ResponseEntity<AgentResponse> approve(@PathVariable UUID id) {
        return ResponseEntity.ok(adminService.approveAgent(id));
    }

    @PatchMapping("/agents/{id}/suspend")
    public ResponseEntity<Void> suspend(@PathVariable UUID id, @RequestParam String reason) {
        adminService.suspendAgent(id, reason); return ResponseEntity.noContent().build();
    }

    @GetMapping("/properties/pending")
    public ResponseEntity<Page<PropertyResponse>> pending(Pageable pageable) {
        return ResponseEntity.ok(adminService.getPendingProperties(pageable));
    }

    @PatchMapping("/properties/{id}/approve")
    public ResponseEntity<PropertyResponse> approveProperty(@PathVariable UUID id) {
        return ResponseEntity.ok(adminService.approveProperty(id));
    }

    @PatchMapping("/properties/{id}/reject")
    public ResponseEntity<Void> rejectProperty(@PathVariable UUID id, @RequestParam String reason) {
        adminService.rejectProperty(id, reason); return ResponseEntity.noContent().build();
    }
}
