package com.skillswap.notification.services;

import com.google.firebase.messaging.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

@Service
@Slf4j
public class FcmService {
    
    @Value("${firebase.enabled:false}")
    private boolean firebaseEnabled;
    
    /**
     * Send FCM notification to user
     * Note: FCM tokens are stored in User Service, not here
     * This is a simplified version that logs notifications
     * In production, you would fetch the token from User Service via Feign client
     */
    public String sendNotification(UUID userId, String title, String body, Map<String, String> data) {
        if (!firebaseEnabled) {
            log.info("Firebase disabled. Notification logged: userId={}, title={}, body={}", 
                    userId, title, body);
            return null;
        }
        
        log.warn("FCM notification requested for user: {} but token retrieval not implemented", userId);
        log.info("To implement: Add Feign client to fetch FCM token from User Service");
        log.info("Notification: {} - {}", title, body);
        
        // TODO: Implement Feign client to User Service to get FCM token
        // String token = userClient.getFcmToken(userId);
        // if (token == null) return null;
        
        // try {
        //     Message message = Message.builder()
        //             .setToken(token)
        //             .setNotification(Notification.builder()
        //                     .setTitle(title)
        //                     .setBody(body)
        //                     .build())
        //             .putAllData(data != null ? data : Map.of())
        //             .build();
        //     
        //     return FirebaseMessaging.getInstance().send(message);
        // } catch (FirebaseMessagingException e) {
        //     log.error("Failed to send FCM: {}", e.getMessage());
        //     return null;
        // }
        
        return null;
    }
}
