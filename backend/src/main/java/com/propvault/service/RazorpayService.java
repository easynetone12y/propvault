package com.propvault.service;

import com.propvault.dto.request.SubscribeRequest;
import com.propvault.dto.response.SubscriptionResponse;
import com.propvault.dto.response.InvoiceResponse;
import org.springframework.data.domain.Page;
import java.util.Map;

public interface RazorpayService {
    Map<String, Object> createSubscription(SubscribeRequest request);
    SubscriptionResponse verifyAndActivate(Map<String, String> payload);
    void handleWebhook(String payload, String signature);
    void cancelSubscription();
    Page<InvoiceResponse> getInvoices(int page);
}
