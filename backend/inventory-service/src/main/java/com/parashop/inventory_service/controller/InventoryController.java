package com.parashop.inventory_service.controller;

import com.parashop.inventory_service.dto.InventoryUpdateDto;
import com.parashop.inventory_service.model.InventoryItem;
import com.parashop.inventory_service.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    @GetMapping("/check")
    public boolean isInStock(@RequestParam String productCode, @RequestParam Integer quantity) {
        return inventoryService.isInStock(productCode, quantity);
    }

    @GetMapping
    public List<InventoryItem> getAll() {
        return inventoryService.getAllInventory();
    }

    @PostMapping("/update")
    public InventoryItem update(@RequestBody InventoryUpdateDto updateDto) {
        return inventoryService.updateInventory(updateDto);
    }

    @GetMapping("/quantity")
    public Integer getQuantity(@RequestParam String productCode) {
        return inventoryService.getQuantity(productCode);
    }
}
