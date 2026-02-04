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
                inventoryRepository.save(new InventoryItem(null, "EUC_001", 100));
                inventoryRepository.save(new InventoryItem(null, "EUC_002", 50));
                inventoryRepository.save(new InventoryItem(null, "VIC_001", 30));
                inventoryRepository.save(new InventoryItem(null, "LAR_001", 80));
                
                System.out.println("Parapharmacy inventory data inserted successfully!");
            }
        };
    }
}
