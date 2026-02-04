package com.parashop.order_service.controller;

import com.parashop.order_service.dto.OrderRequest;
import com.parashop.order_service.dto.OrderResponse;
import com.parashop.order_service.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public String placeOrder(@RequestBody OrderRequest orderRequest) {
        return orderService.placeOrder(orderRequest);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<OrderResponse> getAllOrders() {
        return orderService.getAllOrders();
    }

    @GetMapping("/{username}")
    @ResponseStatus(HttpStatus.OK)
    public List<OrderResponse> getOrdersByUsername(@PathVariable String username) {
        return orderService.getOrdersByUsername(username);
    }

    @PutMapping("/validate/{id}")
    @ResponseStatus(HttpStatus.OK)
    public void validateOrder(@PathVariable Long id) {
        orderService.validateOrder(id);
    }

    @PutMapping("/cancel/{id}")
    @ResponseStatus(HttpStatus.OK)
    public void cancelOrder(@PathVariable Long id) {
        orderService.cancelOrder(id);
    }

    @GetMapping("/stats")
    @ResponseStatus(HttpStatus.OK)
    public List<java.util.Map<String, Object>> getUserStats() {
        return orderService.getUserStats();
    }
}
