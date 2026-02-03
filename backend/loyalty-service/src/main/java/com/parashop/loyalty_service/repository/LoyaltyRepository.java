package com.parashop.loyalty_service.repository;

import com.parashop.loyalty_service.model.Loyalty;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LoyaltyRepository extends JpaRepository<Loyalty, Long> {
    Optional<Loyalty> findByUserId(Long userId);
}
