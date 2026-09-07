package com.propvault.service.impl;

import com.propvault.entity.*;
import com.propvault.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service @RequiredArgsConstructor @Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}") private String from;
    @Value("${propvault.app.url:https://app.propvault.in}") private String appUrl;

    @Override @Async
    public void sendEmailVerification(User user, String token) {
        String link = appUrl + "/verify-email?token=" + token;
        sendEmail(user.getEmail(), "Verify your PropVault email",
            wrap("Verify your email", "<p>Hi " + user.getName() + ",</p>" +
                "<p>Click below to verify your email address:</p>" +
                btn("Verify Email", link) +
                "<p style='color:#6B7280;font-size:12px'>Expires in 24 hours.</p>"));
    }

    @Override @Async
    public void sendPasswordResetEmail(User user, String token) {
        String link = appUrl + "/reset-password?token=" + token;
        sendEmail(user.getEmail(), "Reset your PropVault password",
            wrap("Reset password", "<p>Hi " + user.getName() + ",</p>" +
                "<p>Click below to reset your password:</p>" + btn("Reset Password", link) +
                "<p style='color:#6B7280;font-size:12px'>Expires in 1 hour.</p>"));
    }

    @Override @Async
    public void sendAgentApprovedEmail(Agent agent) {
        sendEmail(agent.getUser().getEmail(), "Agent account approved — PropVault",
            wrap("You're verified! ✅", "<p>Hi " + agent.getUser().getName() + ",</p>" +
                "<p>Your agent account for <strong>" + agent.getCompanyName() +
                "</strong> has been approved. You can now post listings and receive leads.</p>" +
                btn("Go to Dashboard", appUrl + "/agent/dashboard")));
    }

    @Override @Async
    public void sendLeadNotificationToAgent(Lead lead) {
        sendEmail(lead.getAgent().getUser().getEmail(),
            "New lead: " + lead.getProperty().getTitle(),
            wrap("New enquiry", "<p>Hi " + lead.getAgent().getUser().getName() + ",</p>" +
                "<p>New enquiry on <strong>" + lead.getProperty().getTitle() + "</strong></p>" +
                box("👤 " + lead.getCustomerName() + "<br>📞 " + lead.getCustomerPhone()) +
                btn("View Lead", appUrl + "/agent/leads")));
    }

    @Override @Async
    public void sendLeadConfirmationToBuyer(Lead lead) {
        if (lead.getCustomerEmail() == null) return;
        sendEmail(lead.getCustomerEmail(), "Enquiry confirmed",
            wrap("Enquiry sent!", "<p>Your enquiry for <strong>" +
                lead.getProperty().getTitle() + "</strong> has been sent to the agent.</p>" +
                btn("View Property", appUrl + "/properties/" + lead.getProperty().getId())));
    }

    @Override @Async
    public void sendVisitConfirmationToAgent(VisitRequest visit) {
        sendEmail(visit.getAgent().getUser().getEmail(),
            "Visit request: " + visit.getProperty().getTitle(),
            wrap("New visit request", "<p>Hi " + visit.getAgent().getUser().getName() + ",</p>" +
                box("👤 " + visit.getBuyerName() + "<br>📞 " + visit.getBuyerPhone() +
                    "<br>📅 " + visit.getPreferredDate() + " — " + visit.getPreferredTimeSlot()) +
                btn("Confirm Visit", appUrl + "/agent/visits/" + visit.getId())));
    }

    @Override @Async
    public void sendVisitConfirmationToBuyer(VisitRequest visit) {
        if (visit.getBuyerEmail() == null) return;
        sendEmail(visit.getBuyerEmail(), "Visit request received",
            wrap("Visit " + ("CONFIRMED".equals(visit.getStatus()) ? "confirmed!" : "request received"),
                "<p>Your visit for <strong>" + visit.getProperty().getTitle() +
                "</strong> is " + ("CONFIRMED".equals(visit.getStatus()) ? "confirmed." : "pending confirmation.") +
                "</p>" + box("📅 " + visit.getPreferredDate() + " — " + visit.getPreferredTimeSlot())));
    }

    @Override @Async
    public void sendListingApprovedEmail(Agent agent, Property property) {
        if (property == null) return;
        sendEmail(agent.getUser().getEmail(), "Listing approved: " + property.getTitle(),
            wrap("Listing live ✅", "<p>Your listing is now live on PropVault:</p>" +
                box("🏠 " + property.getTitle()) +
                btn("View Listing", appUrl + "/properties/" + property.getId())));
    }

    @Override @Async
    public void sendListingRejectedEmail(Agent agent, Property property, String reason) {
        sendEmail(agent.getUser().getEmail(), "Listing needs revision: " + property.getTitle(),
            wrap("Revision needed", "<p>Your listing was not approved:</p>" +
                box("❌ " + reason) +
                btn("Edit Listing", appUrl + "/agent/properties/" + property.getId() + "/edit")));
    }

    @Override @Async
    public void sendInvoiceEmail(Invoice invoice) {
        sendEmail(invoice.getAgent().getUser().getEmail(),
            "Invoice " + invoice.getInvoiceNumber(),
            wrap("Payment received", box("📄 " + invoice.getInvoiceNumber() +
                "<br>💰 ₹" + invoice.getTotalAmount()) +
                btn("Download Invoice", appUrl + "/agent/invoices/" + invoice.getId())));
    }

    @Override @Async
    public void sendSubscriptionExpiryWarning(Agent agent, int daysLeft) {
        sendEmail(agent.getUser().getEmail(), "Plan expires in " + daysLeft + " days",
            wrap("⏳ Plan expiring", "<p>Your plan expires in <strong>" + daysLeft +
                " days</strong>. Renew now to keep your listings live.</p>" +
                btn("Renew Now", appUrl + "/agent/subscription")));
    }

    // ── Helpers ───────────────────────────────────────────────
    private void sendEmail(String to, String subject, String html) {
        try {
            MimeMessage msg = mailSender.createMimeMessage();
            MimeMessageHelper h = new MimeMessageHelper(msg, true, "UTF-8");
            h.setFrom("PropVault <" + from + ">");
            h.setTo(to); h.setSubject(subject); h.setText(html, true);
            mailSender.send(msg);
            log.info("Email sent → {} [{}]", to, subject);
        } catch (MessagingException e) {
            log.error("Email failed to {}: {}", to, e.getMessage());
        }
    }

    private String wrap(String title, String content) {
        return "<!DOCTYPE html><html><body style='margin:0;background:#F7F8FA;font-family:Inter,Arial,sans-serif'>" +
            "<table width='100%' cellpadding='0' cellspacing='0'><tr><td align='center' style='padding:40px 20px'>" +
            "<table width='580' style='background:#fff;border-radius:12px;overflow:hidden;border:1px solid #E5E7EB'>" +
            "<tr><td style='background:linear-gradient(135deg,#185FA5,#0C447C);padding:20px 28px'>" +
            "<span style='color:#fff;font-size:20px;font-weight:700'><span style='opacity:.7'>Prop</span>Vault</span></td></tr>" +
            "<tr><td style='padding:28px;color:#1F2937;font-size:14px;line-height:1.7'>" +
            "<h2 style='margin:0 0 14px;font-size:18px'>" + title + "</h2>" + content + "</td></tr>" +
            "<tr><td style='padding:16px 28px;background:#F7F8FA;text-align:center;font-size:11px;color:#6B7280'>" +
            "© 2024 PropVault Technologies Pvt. Ltd. · Office No. 410, South Ex Tower, New Delhi 110049" +
            "</td></tr></table></td></tr></table></body></html>";
    }

    private String btn(String label, String url) {
        return "<div style='text-align:center;margin:20px 0'><a href='" + url +
            "' style='background:#185FA5;color:#fff;padding:11px 26px;border-radius:8px;" +
            "text-decoration:none;font-weight:600;font-size:13px'>" + label + "</a></div>";
    }

    private String box(String content) {
        return "<div style='background:#F0F7FF;border-left:4px solid #185FA5;padding:12px 16px;" +
            "border-radius:0 8px 8px 0;margin:14px 0;font-size:13px;line-height:1.8'>" + content + "</div>";
    }
}
