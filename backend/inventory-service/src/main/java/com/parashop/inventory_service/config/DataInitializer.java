package com.parashop.inventory_service.config;

import com.parashop.inventory_service.model.InventoryItem;
import com.parashop.inventory_service.repository.InventoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final InventoryRepository inventoryRepository;

    @Bean
    public CommandLineRunner loadData() {
        return args -> {
            if (inventoryRepository.count() == 0) {
                InventoryItem i1 = InventoryItem.builder()
                        .productCode("DELL-XPS-15")
                        .quantity(10)
                        .build();

                InventoryItem i2 = InventoryItem.builder()
                        .productCode("IPHONE-15-PRO")
                        .quantity(20)
                        .build();

                InventoryItem i3 = InventoryItem.builder()
                        .productCode("GALAXY-BUDS-2")
                        .quantity(50)
                        .build();

                inventoryRepository.saveAll(List.of(i1, i2, i3));
                System.out.println("Test data inserted for inventory-service");
            }
        };
    }
}
