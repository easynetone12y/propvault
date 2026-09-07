package com.propvault.service;

import com.propvault.entity.*;

/**
 * Async transactional email service.
 * All methods are fire-and-forget (@Async) — failures are logged, never thrown.
 */
public interface EmailService {
    void sendEmailVerification(User user, String token);
    void sendPasswordResetEmail(User user, String token);
    void sendAgentApprovedEmail(Agent agent);
    void sendLeadNotificationToAgent(Lead lead);
    void sendLeadConfirmationToBuyer(Lead lead);
    void sendVisitConfirmationToAgent(VisitRequest visit);
    void sendVisitConfirmationToBuyer(VisitRequest visit);
    void sendListingApprovedEmail(Agent agent, Property property);
    void sendListingRejectedEmail(Agent agent, Property property, String reason);
    void sendInvoiceEmail(Invoice invoice);
    void sendSubscriptionExpiryWarning(Agent agent, int daysLeft);
}
