package com.propvault.controller;

import com.propvault.dto.response.NotificationResponse;
import com.propvault.entity.Notification;
import com.propvault.repository.NotificationRepository;
import com.propvault.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController @RequestMapping("/notifications") @RequiredArgsConstructor
@PreAuthorize("isAuthenticated()")
public class NotificationController {
    private final NotificationRepository notifRepo;
    private final SecurityUtil securityUtil;

    @GetMapping
    public ResponseEntity<Page<NotificationResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        UUID uid = securityUtil.getCurrentUserId();
        return ResponseEntity.ok(
            notifRepo.findByUserIdOrderByCreatedAtDesc(uid, pageable).map(this::toDto));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> unreadCount() {
        return ResponseEntity.ok(Map.of("count",
            notifRepo.countByUserIdAndReadFalse(securityUtil.getCurrentUserId())));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllRead() {
        notifRepo.markAllReadForUser(securityUtil.getCurrentUserId());
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markOneRead(@PathVariable UUID id) {
        notifRepo.markOneRead(id, securityUtil.getCurrentUserId());
        return ResponseEntity.noContent().build();
    }

    private NotificationResponse toDto(Notification n) {
        NotificationResponse r = new NotificationResponse();
        r.setId(n.getId()); r.setType(n.getType()); r.setTitle(n.getTitle());
        r.setBody(n.getBody()); r.setData(n.getData());
        r.setRead(n.isRead()); r.setCreatedAt(n.getCreatedAt());
        return r;
    }
}
