package com.propvault.service;

import com.propvault.dto.request.*;
import com.propvault.dto.response.LeadResponse;
import com.propvault.enums.LeadStatus;
import org.springframework.data.domain.*;
import java.util.UUID;

public interface LeadService {
    LeadResponse submit(UUID propertyId, LeadRequest request);
    Page<LeadResponse> getAgentLeads(LeadStatus status, Pageable pageable);
    LeadResponse updateStatus(UUID id, LeadStatusUpdateRequest request);
}
