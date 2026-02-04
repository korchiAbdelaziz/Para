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

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

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

        // 1. Agregation des quantités par produit pour validation globale
        Map<String, Integer> productQuantities = new HashMap<>();
        for (OrderLineItems item : orderLineItems) {
            productQuantities.merge(item.getProductCode(), item.getQuantity(), Integer::sum);
        }

        // 2. Vérification du stock global
        boolean allInStock = productQuantities.entrySet().stream()
                .allMatch(entry -> inventoryClient.isInStock(entry.getKey(), entry.getValue()));

        if (allInStock) {
            order.setStatus("PENDING_VALIDATION");
            orderRepository.save(order);

            // 3. Décrémenter le stock immédiatement (Temps Réel)
            for (Map.Entry<String, Integer> entry : productQuantities.entrySet()) {
                Map<String, Object> updateDto = new HashMap<>();
                updateDto.put("productCode", entry.getKey());
                updateDto.put("quantity", -entry.getValue()); // Négatif pour diminuer
                updateDto.put("unit", "PIECE"); // Par défaut PIECE pour l'instant
                inventoryClient.updateInventory(updateDto);
            }

            return "Commande passée avec succès !";
        } else {
            throw new IllegalArgumentException("Stock insuffisant pour un ou plusieurs produits.");
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

    public void validateOrder(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée"));
        order.setStatus("VALIDATED");
        orderRepository.save(order);
    }

    public void cancelOrder(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée"));
        
        if ("CANCELLED".equals(order.getStatus())) {
            throw new RuntimeException("Commande déjà annulée");
        }

        order.setStatus("CANCELLED");
        orderRepository.save(order);

        // Restaurer le stock pour chaque article
        for (OrderLineItems item : order.getOrderLineItemsList()) {
            Map<String, Object> updateDto = new HashMap<>();
            updateDto.put("productCode", item.getProductCode());
            updateDto.put("quantity", item.getQuantity());
            updateDto.put("unit", "PIECE");
            inventoryClient.updateInventory(updateDto);
        }
    }

    public List<Map<String, Object>> getUserStats() {
        // Simple aggregation by username
        Map<String, Long> orderCounts = orderRepository.findAll().stream()
                .collect(Collectors.groupingBy(Order::getUsername, Collectors.counting()));
        
        return orderCounts.entrySet().stream()
                .map(e -> {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("username", e.getKey());
                    stat.put("orderCount", e.getValue());
                    return stat;
                })
                .sorted((a, b) -> ((Long) b.get("orderCount")).compareTo((Long) a.get("orderCount")))
                .toList();
    }

    private OrderResponse mapToResponse(Order order) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setOrderNumber(order.getOrderNumber());
        response.setUsername(order.getUsername());
        response.setStatus(order.getStatus());
        response.setOrderLineItemsList(order.getOrderLineItemsList().stream()
                .map(item -> new OrderLineItemsResponse(
                        item.getId(),
                        item.getProductCode(),
                        item.getPrice(),
                        item.getQuantity()
                )).toList());
        return response;
    }

    public void updateOrderQuantity(Long orderId, String productCode, Integer newQuantity) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée"));

        if (!"PENDING_VALIDATION".equals(order.getStatus())) {
            throw new RuntimeException("Impossible de modifier une commande validée ou annulée");
        }

        OrderLineItems itemToUpdate = order.getOrderLineItemsList().stream()
                .filter(item -> item.getProductCode().equals(productCode))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Produit non trouvé dans la commande"));

        int oldQuantity = itemToUpdate.getQuantity();
        int delta = newQuantity - oldQuantity;

        if (delta == 0) return;

        // Si on augmente la quantité, vérifier le stock
        if (delta > 0) {
            boolean inStock = inventoryClient.isInStock(productCode, delta);
            if (!inStock) {
                throw new RuntimeException("Stock insuffisant pour augmenter la quantité");
            }
        }

        // Mettre à jour le stock (négatif pour réduire le stock, positif pour restaurer)
        Map<String, Object> updateDto = new HashMap<>();
        updateDto.put("productCode", productCode);
        updateDto.put("quantity", -delta); // Inverse du delta pour l'inventaire
        updateDto.put("unit", "PIECE");
        inventoryClient.updateInventory(updateDto);

        // Mettre à jour la commande
        itemToUpdate.setQuantity(newQuantity);
        if (newQuantity <= 0) {
            order.getOrderLineItemsList().remove(itemToUpdate);
        }
        
        // Si la commande est vide, l'annuler
        if (order.getOrderLineItemsList().isEmpty()) {
            order.setStatus("CANCELLED");
        }

        orderRepository.save(order);
    }

    private OrderLineItems mapToEntity(OrderLineItemsDto orderLineItemsDto) {
        OrderLineItems orderLineItems = new OrderLineItems();
        orderLineItems.setPrice(orderLineItemsDto.getPrice());
        orderLineItems.setQuantity(orderLineItemsDto.getQuantity());
        orderLineItems.setProductCode(orderLineItemsDto.getProductCode());
        return orderLineItems;
    }
}
