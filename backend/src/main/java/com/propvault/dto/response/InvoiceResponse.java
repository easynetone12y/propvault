package com.propvault.dto.response;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class InvoiceResponse {
    private UUID id;
    private String invoiceNumber;
    private BigDecimal subtotal;
    private BigDecimal gstPercent;
    private BigDecimal gstAmount;
    private BigDecimal totalAmount;
    private String razorpayPaymentId;
    private String status;
    private LocalDate invoiceDate;
    private String pdfUrl;
    private LocalDateTime createdAt;
}
