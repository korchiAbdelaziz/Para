package com.parashop.order_service.service;

import com.parashop.order_service.client.InventoryClient;
import com.parashop.order_service.dto.OrderLineItemsDto;
import com.parashop.order_service.dto.OrderRequest;
import com.parashop.order_service.model.Order;
import com.parashop.order_service.model.OrderLineItems;
import com.parashop.order_service.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final InventoryClient inventoryClient;

    public String placeOrder(OrderRequest orderRequest) {
        Order order = new Order();
        order.setOrderNumber(UUID.randomUUID().toString());

        List<OrderLineItems> orderLineItems = orderRequest.getOrderLineItemsDtoList()
                .stream()
                .map(this::mapToDto)
                .toList();

        order.setOrderLineItemsList(orderLineItems);

        // Vérification du stock pour chaque article
        boolean allInStock = order.getOrderLineItemsList().stream()
                .allMatch(item -> inventoryClient.isInStock(item.getProductCode(), item.getQuantity()));

        if (allInStock) {
            orderRepository.save(order);
            return "Commande passée avec succès !";
        } else {
            throw new IllegalArgumentException("Le produit n'est pas en stock, veuillez réessayer plus tard.");
        }
    }

    private OrderLineItems mapToDto(OrderLineItemsDto orderLineItemsDto) {
        OrderLineItems orderLineItems = new OrderLineItems();
        orderLineItems.setPrice(orderLineItemsDto.getPrice());
        orderLineItems.setQuantity(orderLineItemsDto.getQuantity());
        orderLineItems.setProductCode(orderLineItemsDto.getProductCode());
        return orderLineItems;
    }
}
