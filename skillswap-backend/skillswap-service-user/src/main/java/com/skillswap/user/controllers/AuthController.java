package com.skillswap.user.controllers;

import com.skillswap.user.dto.CreateProfileRequest;
import com.skillswap.user.dto.LoginRequest;
import com.skillswap.user.dto.RegisterRequest;
import com.skillswap.user.dto.UserDto;
import com.skillswap.user.services.FirebaseAuthService;
import com.skillswap.user.services.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Authentication Controller
 * 
 * Handles Firebase Auth integration with MongoDB user profiles.
 * 
 * Flow:
 * 1. User signs up → Firebase Auth (client-side)
 * 2. Firebase returns JWT
 * 3. App calls POST /auth/register (with JWT)
 * 4. API Gateway verifies JWT
 * 5. service-user creates:
 *    - Mongo User document
 *    - creditsBalance = 0
 *    - phoneVerified = false
 * 6. Later → PHONE_VERIFIED event → credits +50
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {
    
    private final UserService userService;
    private final FirebaseAuthService firebaseAuthService;
    
    /**
     * POST /auth/register
     * Register a new user after Firebase authentication
     * 
     * This endpoint is called AFTER the user has registered with Firebase Auth.
     * It creates the user profile in MongoDB.
     * 
     * @param request Contains email, fullName, phoneNumber, and Firebase ID token
     * @return The created user profile
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        log.info("POST /auth/register - email: {}", request.getEmail());
        log.debug("Firebase initialized: {}", firebaseAuthService.isFirebaseInitialized());
        log.debug("Token received (first 50 chars): {}", 
            request.getIdToken() != null && request.getIdToken().length() > 50 
                ? request.getIdToken().substring(0, 50) + "..." 
                : request.getIdToken());
        
        // Verify Firebase token
        String firebaseUid = firebaseAuthService.verifyIdToken(request.getIdToken());
        if (firebaseUid == null) {
            log.error("Invalid Firebase token for email: {}. Firebase initialized: {}", 
                request.getEmail(), firebaseAuthService.isFirebaseInitialized());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of(
                    "error", "Invalid Firebase token",
                    "firebaseInitialized", firebaseAuthService.isFirebaseInitialized(),
                    "message", "Token verification failed. Check if Firebase service account is configured correctly."
                ));
        }
        
        // Create profile in MongoDB
        CreateProfileRequest profileRequest = new CreateProfileRequest(
            request.getEmail(),
            request.getPhoneNumber(),
            request.getFullName(),
            request.getIdToken()
        );
        
        UserDto user = userService.createProfile(profileRequest);
        log.info("User registered successfully: {}", user.getUserId());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    /**
     * POST /auth/login
     * Login an existing user
     * 
     * This endpoint is called AFTER the user has logged in with Firebase Auth.
     * It retrieves or creates the user profile in MongoDB.
     * 
     * @param request Contains email and Firebase ID token
     * @return The user profile
     */
    @PostMapping("/login")
    public ResponseEntity<UserDto> login(@Valid @RequestBody LoginRequest request) {
        log.info("POST /auth/login - email: {}", request.getEmail());
        
        // Verify Firebase token
        String firebaseUid = firebaseAuthService.verifyIdToken(request.getIdToken());
        if (firebaseUid == null) {
            log.error("Invalid Firebase token for email: {}", request.getEmail());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(null);
        }
        
        try {
            // Try to get existing user
            UserDto user = userService.getUserByEmail(request.getEmail());
            log.info("User logged in successfully: {}", user.getUserId());
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            // User doesn't exist in MongoDB, create profile
            log.info("User not found in MongoDB, creating profile for: {}", request.getEmail());
            
            CreateProfileRequest profileRequest = new CreateProfileRequest(
                request.getEmail(),
                null, // Phone number not available during login
                request.getEmail().split("@")[0], // Use email prefix as default name
                request.getIdToken()
            );
            
            UserDto user = userService.createProfile(profileRequest);
            log.info("User profile created during login: {}", user.getUserId());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(user);
        }
    }
    
    /**
     * POST /auth/verify-token
     * Verify a Firebase ID token
     * 
     * This endpoint can be used to verify if a token is valid.
     * 
     * @param request Contains the Firebase ID token
     * @return Success message if token is valid
     */
    @PostMapping("/verify-token")
    public ResponseEntity<Map<String, Object>> verifyToken(@RequestBody Map<String, String> request) {
        String idToken = request.get("idToken");
        log.info("POST /auth/verify-token");
        
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);
        if (firebaseUid == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("valid", false, "message", "Invalid token"));
        }
        
        return ResponseEntity.ok(Map.of(
            "valid", true,
            "firebaseUid", firebaseUid
        ));
    }
}
