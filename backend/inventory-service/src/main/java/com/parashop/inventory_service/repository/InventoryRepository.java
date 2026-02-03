package com.parashop.inventory_service.repository;

import com.parashop.inventory_service.model.InventoryItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface InventoryRepository extends JpaRepository<InventoryItem, Long> {
    Optional<InventoryItem> findByProductCode(String productCode);
}
