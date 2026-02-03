package com.parashop.loyalty_service.service;

import com.parashop.loyalty_service.model.Loyalty;
import com.parashop.loyalty_service.repository.LoyaltyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LoyaltyService {

    private final LoyaltyRepository loyaltyRepository;

    public Integer getPoints(Long userId) {
        return loyaltyRepository.findByUserId(userId)
                .map(Loyalty::getPoints)
                .orElse(0);
    }

    public Loyalty addPoints(Long userId, Integer points) {
        Loyalty loyalty = loyaltyRepository.findByUserId(userId)
                .orElse(new Loyalty(null, userId, 0));
        loyalty.setPoints(loyalty.getPoints() + points);
        return loyaltyRepository.save(loyalty);
    }
}
