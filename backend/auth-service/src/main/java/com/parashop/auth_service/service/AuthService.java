package com.parashop.auth_service.service;

import com.parashop.auth_service.dto.UserResponse;
import com.parashop.auth_service.model.UserCredential;
import com.parashop.auth_service.repository.UserCredentialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserCredentialRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public List<UserResponse> getAllUsers() {
        return repository.findAll().stream()
                .map(user -> new UserResponse(user.getId(), user.getName(), user.getEmail(), user.getPhone(), user.getAddress(), user.getProfileImageUrl()))
                .toList();
    }

    public UserResponse getUserByUsername(String username) {
        return repository.findByName(username)
                .map(user -> new UserResponse(user.getId(), user.getName(), user.getEmail(), user.getPhone(), user.getAddress(), user.getProfileImageUrl()))
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    public String updateProfile(UserResponse profile) {
        UserCredential user = repository.findByName(profile.getName())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        
        user.setEmail(profile.getEmail());
        user.setPhone(profile.getPhone());
        user.setAddress(profile.getAddress());
        user.setProfileImageUrl(profile.getProfileImageUrl());
        
        repository.save(user);
        return "Profil mis à jour avec succès";
    }

    public String saveUser(UserCredential credential) {
        credential.setPassword(passwordEncoder.encode(credential.getPassword()));
        repository.save(credential);
        return "Utilisateur ajouté au système";
    }

    public String generateToken(String username) {
        return jwtService.generateToken(username);
    }

    public void validateToken(String token) {
        jwtService.validateToken(token);
    }
}
