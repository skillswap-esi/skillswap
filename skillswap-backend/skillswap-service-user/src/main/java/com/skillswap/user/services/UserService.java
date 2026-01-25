package com.skillswap.user.services;

import com.skillswap.user.dto.CreateProfileRequest;
import com.skillswap.user.dto.LedgerTransactionDto;
import com.skillswap.user.dto.UpdateProfileRequest;
import com.skillswap.user.dto.UserDto;
import com.skillswap.user.exceptions.InvalidTokenException;
import com.skillswap.user.exceptions.UserAlreadyExistsException;
import com.skillswap.user.exceptions.UserNotFoundException;
import com.skillswap.user.mappers.UserMapper;
import com.skillswap.user.model.LedgerTransaction;
import com.skillswap.user.model.User;
import com.skillswap.user.repositories.LedgerTransactionRepository;
import com.skillswap.user.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    
    private final UserRepository userRepository;
    private final LedgerTransactionRepository ledgerTransactionRepository;
    private final UserMapper userMapper;
    private final FirebaseAuthService firebaseAuthService;
    
    private static final int PHONE_VERIFICATION_BONUS = 50;
    
    @Transactional
    public UserDto createProfile(CreateProfileRequest request) {
        log.info("Creating profile for email: {}", request.getEmail());
        
        // Vérifier le token Firebase
        String firebaseUid = firebaseAuthService.verifyIdToken(request.getIdToken());
        if (firebaseUid == null) {
            throw new InvalidTokenException("Invalid Firebase ID token");
        }
        
        // Vérifier l'unicité de l'email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("Email already exists: " + request.getEmail());
        }
        
        // Vérifier l'unicité du téléphone si fourni
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().isEmpty()) {
            if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
                throw new UserAlreadyExistsException("Phone number already exists: " + request.getPhoneNumber());
            }
        }
        
        // Créer l'utilisateur
        User user = new User();
        user.setUserId(UUID.randomUUID());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setFullName(request.getFullName());
        user.setPhoneVerified(false);
        user.setCreditsBalance(0);
        user.setHelperScore(0.0f);
        user.setRoles(List.of("USER"));
        user.setFcmTokens(List.of());
        user.setCreatedAt(new Date());
        user.setUpdatedAt(new Date());
        
        User savedUser = userRepository.save(user);
        log.info("Profile created successfully for userId: {}", savedUser.getUserId());
        
        return userMapper.toDto(savedUser);
    }
    
    public UserDto getUserById(UUID userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        return userMapper.toDto(user);
    }
    
    public UserDto getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new UserNotFoundException("User not found with email: " + email));
        return userMapper.toDto(user);
    }
    
    @Transactional
    public UserDto updateProfile(UUID userId, UpdateProfileRequest request) {
        log.info("Updating profile for userId: {}", userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        
        boolean phoneChanged = false;
        
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().equals(user.getPhoneNumber())) {
            // Vérifier l'unicité du nouveau numéro
            if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
                throw new UserAlreadyExistsException("Phone number already exists: " + request.getPhoneNumber());
            }
            user.setPhoneNumber(request.getPhoneNumber());
            user.setPhoneVerified(false);
            phoneChanged = true;
        }
        
        if (request.getAvatar() != null) {
            user.setAvatar(request.getAvatar());
        }
        
        user.setUpdatedAt(new Date());
        User updatedUser = userRepository.save(user);
        
        log.info("Profile updated successfully for userId: {}", userId);
        
        return userMapper.toDto(updatedUser);
    }
    
    @Transactional
    public UserDto verifyPhone(UUID userId) {
        log.info("Verifying phone for userId: {}", userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        
        if (user.isPhoneVerified()) {
            log.info("Phone already verified for userId: {}", userId);
            return userMapper.toDto(user);
        }
        
        // Marquer le téléphone comme vérifié
        user.setPhoneVerified(true);
        
        // Ajouter le bonus de crédits
        user.setCreditsBalance(user.getCreditsBalance() + PHONE_VERIFICATION_BONUS);
        user.setUpdatedAt(new Date());
        
        User updatedUser = userRepository.save(user);
        
        // Créer une transaction de bonus
        LedgerTransaction bonusTransaction = new LedgerTransaction();
        bonusTransaction.setTransactionId(UUID.randomUUID());
        bonusTransaction.setToUserId(userId);
        bonusTransaction.setAmount(PHONE_VERIFICATION_BONUS);
        bonusTransaction.setTimestamp(new Date());
        bonusTransaction.setDescription("Phone verification bonus");
        ledgerTransactionRepository.save(bonusTransaction);
        
        log.info("Phone verified and bonus credited for userId: {}", userId);
        
        // TODO: Publier un événement PHONE_VERIFIED sur Kafka
        // Exemple:
        // PhoneVerifiedEvent event = new PhoneVerifiedEvent(
        //     userId, 
        //     updatedUser.getEmail(), 
        //     updatedUser.getPhoneNumber(),
        //     PHONE_VERIFICATION_BONUS,
        //     new Date()
        // );
        // kafkaTemplate.send("phone-verified-events", event);
        
        return userMapper.toDto(updatedUser);
    }
    
    public List<LedgerTransactionDto> getLedgerTransactions(UUID userId, int limit) {
        log.info("Fetching ledger transactions for userId: {}, limit: {}", userId, limit);
        
        // Vérifier que l'utilisateur existe
        if (!userRepository.existsById(userId)) {
            throw new UserNotFoundException("User not found: " + userId);
        }
        
        List<LedgerTransaction> transactions = ledgerTransactionRepository
            .findByFromUserIdOrToUserIdOrderByTimestampDesc(
                userId, 
                userId, 
                PageRequest.of(0, limit)
            );
        
        return transactions.stream()
            .map(userMapper::toDto)
            .collect(Collectors.toList());
    }
    
    @Transactional
    public void addCredits(UUID userId, int amount, String description) {
        log.info("Adding {} credits to userId: {}", amount, userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        
        user.setCreditsBalance(user.getCreditsBalance() + amount);
        user.setUpdatedAt(new Date());
        userRepository.save(user);
        
        // Créer une transaction
        LedgerTransaction transaction = new LedgerTransaction();
        transaction.setTransactionId(UUID.randomUUID());
        transaction.setToUserId(userId);
        transaction.setAmount(amount);
        transaction.setTimestamp(new Date());
        transaction.setDescription(description);
        ledgerTransactionRepository.save(transaction);
        
        log.info("Credits added successfully to userId: {}", userId);
    }
    
    @Transactional
    public void deductCredits(UUID userId, int amount, String description) {
        log.info("Deducting {} credits from userId: {}", amount, userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        
        if (user.getCreditsBalance() < amount) {
            throw new IllegalArgumentException("Insufficient credits");
        }
        
        user.setCreditsBalance(user.getCreditsBalance() - amount);
        user.setUpdatedAt(new Date());
        userRepository.save(user);
        
        // Créer une transaction
        LedgerTransaction transaction = new LedgerTransaction();
        transaction.setTransactionId(UUID.randomUUID());
        transaction.setFromUserId(userId);
        transaction.setAmount(amount);
        transaction.setTimestamp(new Date());
        transaction.setDescription(description);
        ledgerTransactionRepository.save(transaction);
        
        log.info("Credits deducted successfully from userId: {}", userId);
    }
    
    @Transactional
    public void transferCredits(UUID fromUserId, UUID toUserId, int amount, UUID missionId) {
        log.info("Transferring {} credits from {} to {}", amount, fromUserId, toUserId);
        
        User fromUser = userRepository.findById(fromUserId)
            .orElseThrow(() -> new UserNotFoundException("From user not found: " + fromUserId));
        
        User toUser = userRepository.findById(toUserId)
            .orElseThrow(() -> new UserNotFoundException("To user not found: " + toUserId));
        
        if (fromUser.getCreditsBalance() < amount) {
            throw new IllegalArgumentException("Insufficient credits");
        }
        
        // Déduire les crédits de l'expéditeur
        fromUser.setCreditsBalance(fromUser.getCreditsBalance() - amount);
        fromUser.setUpdatedAt(new Date());
        
        // Ajouter les crédits au destinataire
        toUser.setCreditsBalance(toUser.getCreditsBalance() + amount);
        toUser.setUpdatedAt(new Date());
        
        userRepository.save(fromUser);
        userRepository.save(toUser);
        
        // Créer une transaction
        LedgerTransaction transaction = new LedgerTransaction();
        transaction.setTransactionId(UUID.randomUUID());
        transaction.setFromUserId(fromUserId);
        transaction.setToUserId(toUserId);
        transaction.setAmount(amount);
        transaction.setMissionId(missionId);
        transaction.setTimestamp(new Date());
        transaction.setDescription("Mission payment");
        ledgerTransactionRepository.save(transaction);
        
        log.info("Credits transferred successfully");
    }
    
    public void saveFcmToken(UUID userId, String fcmToken) {
        log.info("Saving FCM token for userId: {}", userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        
        // Ajouter le token s'il n'existe pas déjà
        if (user.getFcmTokens() == null) {
            user.setFcmTokens(List.of(fcmToken));
        } else if (!user.getFcmTokens().contains(fcmToken)) {
            List<String> tokens = new java.util.ArrayList<>(user.getFcmTokens());
            tokens.add(fcmToken);
            user.setFcmTokens(tokens);
        }
        
        user.setUpdatedAt(new Date());
        userRepository.save(user);
        
        log.info("FCM token saved for userId: {}", userId);
    }
}
