package com.parashop.auth_service.controller;

import com.parashop.auth_service.dto.AuthRequest;
import com.parashop.auth_service.dto.AuthResponse;
import com.parashop.auth_service.dto.UserResponse;
import com.parashop.auth_service.model.UserCredential;
import com.parashop.auth_service.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService service;
    private final AuthenticationManager authenticationManager;

    @GetMapping("/users")
    public List<UserResponse> getAllUsers() {
        return service.getAllUsers();
    }

    @GetMapping("/user/{username}")
    public UserResponse getUserByUsername(@PathVariable String username) {
        return service.getUserByUsername(username);
    }

    @PutMapping("/profile")
    public String updateProfile(@RequestBody UserResponse profile) {
        return service.updateProfile(profile);
    }

    @PostMapping("/register")
    public String addNewUser(@RequestBody UserCredential user) {
        return service.saveUser(user);
    }

    @PostMapping("/token")
    public AuthResponse getToken(@RequestBody AuthRequest authRequest) {
        Authentication authenticate = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(authRequest.getUsername(), authRequest.getPassword()));
        if (authenticate.isAuthenticated()) {
            String token = service.generateToken(authRequest.getUsername());
            return new AuthResponse(token);
        } else {
            throw new RuntimeException("Accès invalide");
        }
    }

    @GetMapping("/validate")
    public String validateToken(@RequestParam("token") String token) {
        service.validateToken(token);
        return "Token valide";
    }
}
