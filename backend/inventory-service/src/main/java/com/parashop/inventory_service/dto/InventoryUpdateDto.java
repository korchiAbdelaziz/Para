package com.parashop.inventory_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class InventoryUpdateDto {
    private String productCode;
    private Integer quantity;
    private String unit; // "PIECE" or "CARTON"
    private Integer piecesPerCarton;
}
