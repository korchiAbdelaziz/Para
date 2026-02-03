package com.parashop.order_service.config;

import com.parashop.order_service.model.Order;
import com.parashop.order_service.model.OrderLineItems;
import com.parashop.order_service.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final OrderRepository orderRepository;

    @Bean
    public CommandLineRunner loadData() {
        return args -> {
            if (orderRepository.count() == 0) {
                OrderLineItems item1 = new OrderLineItems();
                item1.setProductCode("DELL-XPS-15");
                item1.setPrice(BigDecimal.valueOf(1500.00));
                item1.setQuantity(1);

                Order order1 = new Order();
                order1.setOrderNumber(UUID.randomUUID().toString());
                order1.setOrderLineItemsList(List.of(item1));

                OrderLineItems item2 = new OrderLineItems();
                item2.setProductCode("IPHONE-15-PRO");
                item2.setPrice(BigDecimal.valueOf(1200.00));
                item2.setQuantity(2);

                Order order2 = new Order();
                order2.setOrderNumber(UUID.randomUUID().toString());
                order2.setOrderLineItemsList(List.of(item2));

                orderRepository.saveAll(List.of(order1, order2));
                System.out.println("Test data inserted for order-service");
            }
        };
    }
}
