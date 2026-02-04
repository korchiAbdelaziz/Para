package com.parashop.inventory_service.service;

import com.parashop.inventory_service.dto.InventoryUpdateDto;
import com.parashop.inventory_service.model.InventoryItem;
import com.parashop.inventory_service.repository.InventoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InventoryService {

    private final InventoryRepository inventoryRepository;

    @Transactional(readOnly = true)
    public boolean isInStock(String productCode, Integer quantity) {
        return inventoryRepository.findByProductCode(productCode)
                .map(item -> item.getQuantity() >= quantity)
                .orElse(false);
    }

    public List<InventoryItem> getAllInventory() {
        return inventoryRepository.findAll();
    }

    public InventoryItem updateInventory(InventoryUpdateDto updateDto) {
        int totalQuantityToAdd = updateDto.getQuantity();
        if ("CARTON".equalsIgnoreCase(updateDto.getUnit()) && updateDto.getPiecesPerCarton() != null) {
            totalQuantityToAdd = updateDto.getQuantity() * updateDto.getPiecesPerCarton();
        }

        InventoryItem item = inventoryRepository.findByProductCode(updateDto.getProductCode())
                .orElse(InventoryItem.builder().productCode(updateDto.getProductCode()).quantity(0).build());
        item.setQuantity(item.getQuantity() + totalQuantityToAdd);
        return inventoryRepository.save(item);
    }
}
