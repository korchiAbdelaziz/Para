package com.parashop.order_service.service;

import com.parashop.order_service.dto.OrderLineItemsResponse;
import com.parashop.order_service.dto.OrderResponse;
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
        order.setUsername(orderRequest.getUsername());

        List<OrderLineItems> orderLineItems = orderRequest.getOrderLineItemsDtoList()
                .stream()
                .map(this::mapToEntity)
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

    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::mapToResponse)
                .toList();
    }

    public List<OrderResponse> getOrdersByUsername(String username) {
        return orderRepository.findAll().stream()
                .filter(order -> username.equals(order.getUsername()))
                .map(this::mapToResponse)
                .toList();
    }

    private OrderResponse mapToResponse(Order order) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setOrderNumber(order.getOrderNumber());
        response.setUsername(order.getUsername());
        response.setOrderLineItemsList(order.getOrderLineItemsList().stream()
                .map(item -> new OrderLineItemsResponse(
                        item.getId(),
                        item.getProductCode(),
                        item.getPrice(),
                        item.getQuantity()
                )).toList());
        return response;
    }

    private OrderLineItems mapToEntity(OrderLineItemsDto orderLineItemsDto) {
        OrderLineItems orderLineItems = new OrderLineItems();
        orderLineItems.setPrice(orderLineItemsDto.getPrice());
        orderLineItems.setQuantity(orderLineItemsDto.getQuantity());
        orderLineItems.setProductCode(orderLineItemsDto.getProductCode());
        return orderLineItems;
    }
}
