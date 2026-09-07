package com.propvault.service;

import com.propvault.dto.response.*;
import org.springframework.data.domain.*;
import java.util.UUID;

public interface AdminService {
    DashboardStatsResponse getDashboardStats();
    Page<AgentResponse> getAllAgents(String status, Pageable pageable);
    AgentResponse approveAgent(UUID agentId);
    void suspendAgent(UUID agentId, String reason);
    Page<PropertyResponse> getPendingProperties(Pageable pageable);
    PropertyResponse approveProperty(UUID propertyId);
    void rejectProperty(UUID propertyId, String reason);
}
