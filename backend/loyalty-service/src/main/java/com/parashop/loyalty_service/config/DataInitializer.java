package com.parashop.loyalty_service.config;

import com.parashop.loyalty_service.model.Loyalty;
import com.parashop.loyalty_service.repository.LoyaltyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final LoyaltyRepository loyaltyRepository;

    @Bean
    public CommandLineRunner loadData() {
        return args -> {
            if (loyaltyRepository.count() == 0) {
                Loyalty l1 = new Loyalty();
                l1.setUserId(1L);
                l1.setPoints(100);

                Loyalty l2 = new Loyalty();
                l2.setUserId(2L);
                l2.setPoints(250);

                loyaltyRepository.saveAll(List.of(l1, l2));
                System.out.println("Test data inserted for loyalty-service");
            }
        };
    }
}
