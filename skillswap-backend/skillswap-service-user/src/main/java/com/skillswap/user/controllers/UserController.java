package com.skillswap.user.controllers;

import com.skillswap.user.dto.*;
import com.skillswap.user.services.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {
    
    private final UserService userService;
    
    /**
     * GET /users/me
     * Récupère le profil de l'utilisateur connecté
     * 
     * NOTE: Pour l'instant, userId est passé en paramètre.
     * Dans une implémentation complète avec Spring Security,
     * l'userId serait extrait du JWT token.
     */
    @GetMapping("/me")
    public ResponseEntity<UserDto> getCurrentUser(@RequestParam UUID userId) {
        log.info("GET /users/me - userId: {}", userId);
        UserDto user = userService.getUserById(userId);
        return ResponseEntity.ok(user);
    }
    
    /**
     * POST /users/profile
     * Crée un nouveau profil utilisateur après inscription Firebase
     */
    @PostMapping("/profile")
    public ResponseEntity<UserDto> createProfile(@Valid @RequestBody CreateProfileRequest request) {
        log.info("POST /users/profile - email: {}", request.getEmail());
        UserDto user = userService.createProfile(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    /**
     * PUT /users/me
     * Met à jour le profil de l'utilisateur connecté
     */
    @PutMapping("/me")
    public ResponseEntity<UserDto> updateProfile(
            @RequestParam UUID userId,
            @Valid @RequestBody UpdateProfileRequest request) {
        log.info("PUT /users/me - userId: {}", userId);
        UserDto user = userService.updateProfile(userId, request);
        return ResponseEntity.ok(user);
    }
    
    /**
     * POST /users/fcm-tokens
     * Enregistre le token FCM pour les notifications push
     */
    @PostMapping("/fcm-tokens")
    public ResponseEntity<Map<String, String>> saveFcmToken(
            @RequestParam UUID userId,
            @Valid @RequestBody FcmTokenRequest request) {
        log.info("POST /users/fcm-tokens - userId: {}", userId);
        userService.saveFcmToken(userId, request.getFcmToken());
        return ResponseEntity.ok(Map.of("message", "FCM token saved successfully"));
    }
    
    /**
     * GET /users/ledger
     * Récupère l'historique des transactions de crédits
     */
    @GetMapping("/ledger")
    public ResponseEntity<List<LedgerTransactionDto>> getLedgerTransactions(
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "50") int limit) {
        log.info("GET /users/ledger - userId: {}, limit: {}", userId, limit);
        List<LedgerTransactionDto> transactions = userService.getLedgerTransactions(userId, limit);
        return ResponseEntity.ok(transactions);
    }
    
    /**
     * POST /users/{userId}/verify-phone
     * Vérifie le numéro de téléphone et attribue le bonus
     */
    @PostMapping("/{userId}/verify-phone")
    public ResponseEntity<UserDto> verifyPhone(@PathVariable UUID userId) {
        log.info("POST /users/{}/verify-phone", userId);
        UserDto user = userService.verifyPhone(userId);
        return ResponseEntity.ok(user);
    }
    
    /**
     * GET /users/{userId}
     * Récupère un utilisateur par son ID (endpoint interne pour les autres services)
     */
    @GetMapping("/{userId}")
    public ResponseEntity<UserDto> getUserById(@PathVariable UUID userId) {
        log.info("GET /users/{}", userId);
        UserDto user = userService.getUserById(userId);
        return ResponseEntity.ok(user);
    }
    
    /**
     * GET /users/email/{email}
     * Récupère un utilisateur par son email (endpoint interne)
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<UserDto> getUserByEmail(@PathVariable String email) {
        log.info("GET /users/email/{}", email);
        UserDto user = userService.getUserByEmail(email);
        return ResponseEntity.ok(user);
    }
    
    /**
     * POST /users/{userId}/credits/add
     * Ajoute des crédits à un utilisateur (endpoint interne)
     */
    @PostMapping("/{userId}/credits/add")
    public ResponseEntity<Map<String, String>> addCredits(
            @PathVariable UUID userId,
            @RequestParam int amount,
            @RequestParam(required = false, defaultValue = "Credit added") String description) {
        log.info("POST /users/{}/credits/add - amount: {}", userId, amount);
        userService.addCredits(userId, amount, description);
        return ResponseEntity.ok(Map.of("message", "Credits added successfully"));
    }
    
    /**
     * POST /users/{userId}/credits/deduct
     * Déduit des crédits d'un utilisateur (endpoint interne)
     */
    @PostMapping("/{userId}/credits/deduct")
    public ResponseEntity<Map<String, String>> deductCredits(
            @PathVariable UUID userId,
            @RequestParam int amount,
            @RequestParam(required = false, defaultValue = "Credit deducted") String description) {
        log.info("POST /users/{}/credits/deduct - amount: {}", userId, amount);
        userService.deductCredits(userId, amount, description);
        return ResponseEntity.ok(Map.of("message", "Credits deducted successfully"));
    }
    
    /**
     * POST /users/credits/transfer
     * Transfère des crédits entre utilisateurs (endpoint interne pour les missions)
     */
    @PostMapping("/credits/transfer")
    public ResponseEntity<Map<String, String>> transferCredits(
            @RequestParam UUID fromUserId,
            @RequestParam UUID toUserId,
            @RequestParam int amount,
            @RequestParam(required = false) UUID missionId) {
        log.info("POST /users/credits/transfer - from: {}, to: {}, amount: {}", 
                fromUserId, toUserId, amount);
        userService.transferCredits(fromUserId, toUserId, amount, missionId);
        return ResponseEntity.ok(Map.of("message", "Credits transferred successfully"));
    }
    
    /**
     * POST /users/{userId}/credits/debit
     * Débite des crédits d'un utilisateur (endpoint interne pour Mission Service)
     * Alias pour /credits/deduct
     */
    @PostMapping("/{userId}/credits/debit")
    public ResponseEntity<Void> debitCredits(
            @PathVariable UUID userId,
            @RequestParam int amount) {
        log.info("POST /users/{}/credits/debit - amount: {}", userId, amount);
        userService.deductCredits(userId, amount, "Mission payment");
        return ResponseEntity.ok().build();
    }
    
    /**
     * POST /users/{userId}/credits/credit
     * Crédite des crédits à un utilisateur (endpoint interne pour Mission Service)
     * Alias pour /credits/add
     */
    @PostMapping("/{userId}/credits/credit")
    public ResponseEntity<Void> creditCredits(
            @PathVariable UUID userId,
            @RequestParam int amount) {
        log.info("POST /users/{}/credits/credit - amount: {}", userId, amount);
        userService.addCredits(userId, amount, "Mission refund/payment");
        return ResponseEntity.ok().build();
    }
}
