package com.parashop.product_service.dto;

import com.opencsv.bean.CsvBindByName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

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
    @CsvBindByName(column = "discountPrice")
    private BigDecimal discountPrice;
    @CsvBindByName(column = "productCode")
    private String productCode;
    @CsvBindByName(column = "imageUrls")
    private String imageUrlsCsv; // For CSV bulk upload (comma separated)
    
    private List<String> imageUrls; // For JSON requests
    
    @CsvBindByName(column = "quantity")
    private Integer quantity;

    @CsvBindByName(column = "category")
    private String category;
}
