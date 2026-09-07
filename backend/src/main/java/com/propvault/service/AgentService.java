package com.propvault.service;

import com.propvault.dto.request.AgentProfileRequest;
import com.propvault.dto.response.*;
import org.springframework.data.domain.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.UUID;

public interface AgentService {
    AgentProfileResponse getPublicProfile(UUID agentId);
    AgentProfileResponse getMyProfile();
    AgentProfileResponse updateMyProfile(AgentProfileRequest req);
    AgentProfileResponse uploadLogo(MultipartFile logo);
    PagedResponse<PropertyResponse> getAgentProperties(UUID agentId, Pageable pageable);
    DashboardStatsResponse getMyStats();
    SubscriptionResponse getMySubscription();
}
