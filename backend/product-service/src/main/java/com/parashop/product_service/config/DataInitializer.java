package com.parashop.product_service.config;

import com.parashop.product_service.model.Category;
import com.parashop.product_service.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final CategoryRepository categoryRepository;

    @Override
    public void run(String... args) throws Exception {
        if (categoryRepository.count() == 0) {
            List<String> categories = Arrays.asList(
                "Soin du Visage",
                "Soin du Corps",
                "Hygiène Dentaire",
                "Compléments Alimentaires",
                "Bébé & Maman",
                "Solaire",
                "Cheveux"
            );
            
            categories.forEach(name -> 
                categoryRepository.save(Category.builder().name(name).build())
            );
        }
    }
}
