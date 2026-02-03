package com.parashop.auth_service.config;

import com.parashop.auth_service.model.UserCredential;
import com.parashop.auth_service.repository.UserCredentialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final UserCredentialRepository userCredentialRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner loadData() {
        return args -> {
            if (userCredentialRepository.count() == 0) {
                UserCredential admin = new UserCredential();
                admin.setName("admin");
                admin.setEmail("admin@parashop.com");
                admin.setPassword(passwordEncoder.encode("admin123"));

                UserCredential user = new UserCredential();
                user.setName("user");
                user.setEmail("user@example.com");
                user.setPassword(passwordEncoder.encode("user123"));

                userCredentialRepository.saveAll(List.of(admin, user));
                System.out.println("Test data inserted for auth-service");
            }
        };
    }
}
