package com.propvault.util;

import com.propvault.entity.User;
import com.propvault.exception.ApiException;
import com.propvault.repository.AgentRepository;
import com.propvault.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import java.util.UUID;

@Component @RequiredArgsConstructor
public class SecurityUtil {
    private final UserRepository userRepo;
    private final AgentRepository agentRepo;

    public String getCurrentUserEmail() {
        return SecurityContextHolder.getContext().getAuthentication().getName();
    }

    public User getCurrentUser() {
        return userRepo.findByEmail(getCurrentUserEmail())
            .orElseThrow(() -> ApiException.unauthorized("User not found"));
    }

    public UUID getCurrentUserId() { return getCurrentUser().getId(); }

    public UUID getCurrentAgentId() {
        UUID userId = getCurrentUserId();
        return agentRepo.findByUserId(userId)
            .map(a -> a.getId())
            .orElseThrow(() -> ApiException.notFound("Agent profile not found"));
    }
}
