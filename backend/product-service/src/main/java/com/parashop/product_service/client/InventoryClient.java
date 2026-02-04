package com.parashop.product_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@FeignClient(name = "inventory-service")
public interface InventoryClient {
    @GetMapping("/api/inventory/check")
    boolean isInStock(@RequestParam String productCode, @RequestParam Integer quantity);

    @PostMapping("/api/inventory/update")
    void updateInventory(@RequestBody Map<String, Object> updateDto);

    @GetMapping("/api/inventory/quantity")
    Integer getQuantity(@RequestParam String productCode);
}
