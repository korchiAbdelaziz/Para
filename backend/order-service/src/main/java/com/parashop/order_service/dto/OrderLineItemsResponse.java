package com.parashop.order_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OrderLineItemsResponse {
    private Long id;
    private String productCode;
    private BigDecimal price;
    private Integer quantity;
}
