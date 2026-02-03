package com.parashop.loyalty_service.controller;

import com.parashop.loyalty_service.model.Loyalty;
import com.parashop.loyalty_service.service.LoyaltyService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/loyalty")
@RequiredArgsConstructor
public class LoyaltyController {

    private final LoyaltyService loyaltyService;

    @GetMapping("/{userId}")
    public Integer getPoints(@PathVariable Long userId) {
        return loyaltyService.getPoints(userId);
    }

    @PostMapping("/add")
    public Loyalty addPoints(@RequestParam Long userId, @RequestParam Integer points) {
        return loyaltyService.addPoints(userId, points);
    }
}
