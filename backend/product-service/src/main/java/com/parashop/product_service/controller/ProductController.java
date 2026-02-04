package com.parashop.product_service.controller;

import com.parashop.product_service.dto.ProductRequest;
import com.parashop.product_service.dto.ProductResponse;
import com.parashop.product_service.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void createProduct(@RequestBody ProductRequest productRequest) {
        productService.createProduct(productRequest);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<ProductResponse> getAllProducts(@RequestParam(required = false, defaultValue = "false") boolean filterStock) {
        return productService.getAllProducts(filterStock);
    }

    @PutMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public void updateProduct(@PathVariable Long id, @RequestBody ProductRequest productRequest) {
        productService.updateProduct(id, productRequest);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
    }

    @PostMapping("/bulk")
    @ResponseStatus(HttpStatus.CREATED)
    public List<ProductRequest> bulkUpload(@RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        return productService.uploadBulk(file);
    }

    @PostMapping("/upload-image")
    @ResponseStatus(HttpStatus.OK)
    public String uploadImage(@RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        return productService.uploadImage(file);
    }
}
