package com.parashop.product_service.service;

import com.parashop.product_service.client.InventoryClient;
import com.parashop.product_service.dto.ProductRequest;
import com.parashop.product_service.dto.ProductResponse;
import com.parashop.product_service.model.Category;
import com.parashop.product_service.model.Product;
import com.parashop.product_service.model.ProductImage;
import com.parashop.product_service.repository.CategoryRepository;
import com.parashop.product_service.repository.ProductRepository;
import com.opencsv.bean.CsvToBean;
import com.opencsv.bean.CsvToBeanBuilder;
import com.opencsv.bean.HeaderColumnNameMappingStrategy;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.beans.factory.annotation.Value;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final InventoryClient inventoryClient;

    public void createProduct(ProductRequest productRequest) {
        Product product = Product.builder()
                .name(productRequest.getName())
                .description(productRequest.getDescription())
                .price(productRequest.getPrice())
                .discountPrice(productRequest.getDiscountPrice())
                .productCode(productRequest.getProductCode())
                .category(getOrCreateCategory(productRequest.getCategory()))
                .build();

        // Handle images
        List<String> imageUrls = productRequest.getImageUrls();
        if (imageUrls == null && productRequest.getImageUrlsCsv() != null) {
            imageUrls = List.of(productRequest.getImageUrlsCsv().split(","));
        }

        if (imageUrls != null) {
            List<ProductImage> productImages = imageUrls.stream()
                    .map(url -> ProductImage.builder().imageUrl(url.trim()).product(product).build())
                    .toList();
            product.setImages(new ArrayList<>(productImages));
        }

        productRepository.save(product);
        log.info("Produit {} est sauvegardé", product.getId());

        // Handle initial stock
        if (productRequest.getQuantity() != null && productRequest.getQuantity() > 0) {
            try {
                java.util.Map<String, Object> stockUpdate = new java.util.HashMap<>();
                stockUpdate.put("productCode", product.getProductCode());
                stockUpdate.put("quantity", productRequest.getQuantity());
                stockUpdate.put("unit", "PIECE"); // Default
                inventoryClient.updateInventory(stockUpdate);
                log.info("Stock initialisé pour le produit {}: {}", product.getProductCode(), productRequest.getQuantity());
            } catch (Exception e) {
                log.error("Erreur lors de l'initialisation du stock pour {}: {}", product.getProductCode(), e.getMessage());
                // Non-blocking error
            }
        }
    }

    public List<ProductResponse> getAllProducts(boolean filterStock) {
        List<Product> products = productRepository.findAll();

        return products.stream()
                .map(this::mapToProductResponse)
                .filter(response -> !filterStock || response.isInStock())
                .toList();
    }

    public void updateProduct(Long id, ProductRequest productRequest) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produit non trouvé avec l'id : " + id));

        product.setName(productRequest.getName());
        product.setDescription(productRequest.getDescription());
        product.setPrice(productRequest.getPrice());
        product.setDiscountPrice(productRequest.getDiscountPrice());
        product.setProductCode(productRequest.getProductCode());
        product.setCategory(getOrCreateCategory(productRequest.getCategory()));

        // Update images
        List<String> imageUrls = productRequest.getImageUrls();
        if (imageUrls == null && productRequest.getImageUrlsCsv() != null) {
            imageUrls = List.of(productRequest.getImageUrlsCsv().split(","));
        }

        if (imageUrls != null) {
            product.getImages().clear();
            List<ProductImage> newImages = imageUrls.stream()
                    .map(url -> ProductImage.builder().imageUrl(url.trim()).product(product).build())
                    .toList();
            product.getImages().addAll(newImages);
        }

        productRepository.save(product);
        log.info("Produit {} est mis à jour", id);

        // Handle stock adjustment
        if (productRequest.getQuantity() != null && productRequest.getQuantity() != 0) {
            try {
                java.util.Map<String, Object> stockUpdate = new java.util.HashMap<>();
                stockUpdate.put("productCode", product.getProductCode());
                stockUpdate.put("quantity", productRequest.getQuantity());
                stockUpdate.put("unit", "PIECE");
                inventoryClient.updateInventory(stockUpdate);
                log.info("Stock ajusté pour le produit {}: {}", product.getProductCode(), productRequest.getQuantity());
            } catch (Exception e) {
                log.error("Erreur lors de l'ajustement du stock pour {}: {}", product.getProductCode(), e.getMessage());
            }
        }
    }

    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
        log.info("Produit {} est supprimé", id);
    }

    public List<ProductRequest> uploadBulk(MultipartFile file) {
        log.info("Début de l'import bulk pour le fichier: {}", file.getOriginalFilename());
        List<ProductRequest> invalidEntries = new ArrayList<>();
        try (Reader reader = new BufferedReader(new InputStreamReader(file.getInputStream(), StandardCharsets.UTF_8))) {
            HeaderColumnNameMappingStrategy<ProductRequest> strategy = new HeaderColumnNameMappingStrategy<>();
            strategy.setType(ProductRequest.class);

            CsvToBean<ProductRequest> csvToBean = new CsvToBeanBuilder<ProductRequest>(reader)
                    .withMappingStrategy(strategy)
                    .withIgnoreLeadingWhiteSpace(true)
                    .withType(ProductRequest.class)
                    .build();

            List<ProductRequest> productRequests = csvToBean.parse();
            int successCount = 0;
            int failCount = 0;

            for (ProductRequest request : productRequests) {
                if (isInvalid(request)) {
                    invalidEntries.add(request);
                    continue;
                }
                try {
                    createProduct(request);
                    successCount++;
                } catch (Exception e) {
                    invalidEntries.add(request);
                    log.error("Erreur lors de la création du produit {}: {}", request.getName(), e.getMessage());
                }
            }
            log.info("Import terminé: {} succès, {} à corriger", successCount, invalidEntries.size());
            return invalidEntries;
        } catch (Exception e) {
            log.error("Erreur critique lors de l'import CSV: {}", e.getMessage(), e);
            throw new RuntimeException("Erreur de traitement du fichier CSV: " + e.getMessage());
        }
    }

    private boolean isInvalid(ProductRequest request) {
        return request.getName() == null || request.getName().isEmpty() ||
               request.getPrice() == null ||
               request.getProductCode() == null || request.getProductCode().isEmpty();
    }

    public String uploadImage(MultipartFile file) {
        try {
            String uploadDir = "uploads/images/";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
            Path path = Paths.get(uploadDir + fileName);
            Files.copy(file.getInputStream(), path);

            return "http://localhost:8888/api/product/images/" + fileName;
        } catch (Exception e) {
            log.error("Erreur lors de l'upload de l'image: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de l'enregistrement de l'image");
        }
    }

    private ProductResponse mapToProductResponse(Product product) {
        boolean isInStock = false;
        try {
            // Vérification du stock via Feign Client (demandant 1 unité par défaut)
            isInStock = inventoryClient.isInStock(product.getProductCode(), 1);
        } catch (Exception e) {
            log.error("Erreur lors de la vérification du stock pour {}: {}", product.getProductCode(), e.getMessage());
        }

        return ProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .discountPrice(product.getDiscountPrice())
                .productCode(product.getProductCode())
                .imageUrls(product.getImages() != null ? product.getImages().stream().map(ProductImage::getImageUrl).toList() : List.of())
                .category(product.getCategory() != null ? product.getCategory().getName() : null)
                .isInStock(isInStock)
                .build();
    }

    private Category getOrCreateCategory(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        return categoryRepository.findByName(categoryName)
                .orElseGet(() -> categoryRepository.save(Category.builder().name(categoryName).build()));
    }
}
