package com.parashop.product_service.dto;

import com.opencsv.bean.CsvBindByName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProductRequest {
    @CsvBindByName(column = "name")
    private String name;
    @CsvBindByName(column = "description")
    private String description;
    @CsvBindByName(column = "price")
    private BigDecimal price;
    @CsvBindByName(column = "productCode")
    private String productCode;
    @CsvBindByName(column = "imageUrl")
    private String imageUrl;
    @CsvBindByName(column = "category")
    private String category;
}
