package com.propvault.controller;

import com.propvault.entity.SubscriptionPlan;
import com.propvault.repository.SubscriptionPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController @RequestMapping("/subscription-plans") @RequiredArgsConstructor
public class SubscriptionPlanController {
    private final SubscriptionPlanRepository planRepo;

    @GetMapping
    public ResponseEntity<List<SubscriptionPlan>> getAll() {
        return ResponseEntity.ok(planRepo.findByActiveTrueOrderBySortOrderAsc());
    }
}
