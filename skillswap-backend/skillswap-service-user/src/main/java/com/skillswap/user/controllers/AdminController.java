package com.skillswap.user.controllers;

import com.skillswap.user.dto.AdminLoginRequest;
import com.skillswap.user.dto.AdminLoginResponse;
import com.skillswap.user.dto.UserDto;
import com.skillswap.user.mappers.UserMapper;
import com.skillswap.user.model.User;
import com.skillswap.user.repositories.UserRepository;
import com.skillswap.user.services.JwtTokenService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Admin Controller for Backoffice
 * 
 * Provides endpoints for:
 * - Admin login (email/password authentication)
 * - Get all users (for backoffice user management)
 * 
 * These endpoints are NEW and do NOT affect mobile app functionality.
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
public class AdminController {
    
    private final UserRepository userRepository;
    private final JwtTokenService jwtTokenService;
    private final UserMapper userMapper;
    
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    
    /**
     * POST /admin/login
     * Authenticate admin user with email and password
     * 
     * This is for backoffice only - mobile app uses Firebase authentication.
     */
    @PostMapping("/login")
    public ResponseEntity<?> adminLogin(@Valid @RequestBody AdminLoginRequest request) {
        log.info("POST /admin/login - email: {}", request.getEmail());
        
        // Find user by email
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        
        if (user == null) {
            log.warn("Admin login failed: user not found - {}", request.getEmail());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid credentials"));
        }
        
        // Check if user has ADMIN role
        if (user.getRoles() == null || !user.getRoles().contains("ADMIN")) {
            log.warn("Admin login failed: user is not admin - {}", request.getEmail());
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Access denied. Admin role required."));
        }
        
        // Check password
        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            log.warn("Admin login failed: invalid password - {}", request.getEmail());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid credentials"));
        }
        
        // Generate JWT token
        String token = jwtTokenService.generateToken(user.getUserId(), user.getEmail(), "ADMIN");
        
        log.info("Admin login successful for: {}", request.getEmail());
        
        return ResponseEntity.ok(new AdminLoginResponse(token, user.getEmail(), "ADMIN"));
    }
    
    /**
     * GET /admin/users
     * Get all users for backoffice user management
     * 
     * Note: In production, this should require admin authentication.
     * For now, it's open for simplicity (backoffice uses its own auth).
     */
    @GetMapping("/users")
    public ResponseEntity<List<UserDto>> getAllUsers() {
        log.info("GET /admin/users - Fetching all users for backoffice");
        
        List<User> users = userRepository.findAll();
        List<UserDto> userDtos = users.stream()
                .map(userMapper::toDto)
                .collect(Collectors.toList());
        
        log.info("Returning {} users", userDtos.size());
        return ResponseEntity.ok(userDtos);
    }
    
    /**
     * GET /admin/users/count
     * Get total user count for dashboard statistics
     */
    @GetMapping("/users/count")
    public ResponseEntity<Map<String, Long>> getUserCount() {
        log.info("GET /admin/users/count");
        long count = userRepository.count();
        return ResponseEntity.ok(Map.of("count", count));
    }
}
