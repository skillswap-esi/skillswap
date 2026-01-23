package com.skillswap.notification.services;

import com.google.firebase.messaging.*;
import com.skillswap.notification.model.FcmToken;
import com.skillswap.notification.repositories.FcmTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class FcmService {
    
    private final FcmTokenRepository fcmTokenRepository;
    
    @Value("${firebase.enabled:false}")
    private boolean firebaseEnabled;
    
    public void registerToken(UUID userId, String token, String deviceType) {
        log.info("Registering FCM token for user: {}", userId);
        
        Optional<FcmToken> existing = fcmTokenRepository.findByUserId(userId);
        
        FcmToken fcmToken;
        if (existing.isPresent()) {
            fcmToken = existing.get();
            fcmToken.setToken(token);
            fcmToken.setDeviceType(deviceType);
            fcmToken.setActive(true);
        } else {
            fcmToken = new FcmToken();
            fcmToken.setId(UUID.randomUUID());
            fcmToken.setUserId(userId);
            fcmToken.setToken(token);
            fcmToken.setDeviceType(deviceType);
            fcmToken.setActive(true);
        }
        
        fcmTokenRepository.save(fcmToken);
        log.info("FCM token registered successfully");
    }
    
    public String sendNotification(UUID userId, String title, String body, Map<String, String> data) {
        if (!firebaseEnabled) {
            log.info("Firebase disabled. Notification not sent: {} - {}", title, body);
            return null;
        }
        
        Optional<FcmToken> fcmTokenOpt = fcmTokenRepository.findByUserId(userId);
        
        if (fcmTokenOpt.isEmpty() || !fcmTokenOpt.get().isActive()) {
            log.warn("No active FCM token found for user: {}", userId);
            return null;
        }
        
        String token = fcmTokenOpt.get().getToken();
        
        try {
            Message.Builder messageBuilder = Message.builder()
                    .setToken(token)
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());
            
            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }
            
            String response = FirebaseMessaging.getInstance().send(messageBuilder.build());
            log.info("FCM notification sent successfully: {}", response);
            return response;
            
        } catch (FirebaseMessagingException e) {
            log.error("Failed to send FCM notification to user {}: {}", userId, e.getMessage());
            
            // Deactivate token if it's invalid
            if (e.getMessagingErrorCode() == MessagingErrorCode.INVALID_ARGUMENT ||
                e.getMessagingErrorCode() == MessagingErrorCode.UNREGISTERED) {
                FcmToken fcmToken = fcmTokenOpt.get();
                fcmToken.setActive(false);
                fcmTokenRepository.save(fcmToken);
                log.info("Deactivated invalid FCM token for user: {}", userId);
            }
            
            return null;
        }
    }
    
    public void unregisterToken(UUID userId) {
        log.info("Unregistering FCM token for user: {}", userId);
        fcmTokenRepository.findByUserId(userId).ifPresent(token -> {
            token.setActive(false);
            fcmTokenRepository.save(token);
        });
    }
}
