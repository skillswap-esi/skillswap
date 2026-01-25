package com.skillswap.notification.services;

import com.skillswap.notification.enums.NotificationType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    
    private final FcmService fcmService;
    
    /**
     * Send notification via FCM only
     * No database storage - notifications are stored in Firestore by mobile app
     */
    public void sendNotification(
            UUID userId,
            NotificationType type,
            String title,
            String message,
            Map<String, Object> data
    ) {
        log.info("Sending notification to user: {}, type: {}", userId, type);
        
        try {
            // Prepare FCM data
            Map<String, String> fcmData = new HashMap<>();
            fcmData.put("type", type.toString());
            if (data != null) {
                data.forEach((key, value) -> fcmData.put(key, value.toString()));
            }
            
            // Send FCM notification
            String messageId = fcmService.sendNotification(userId, title, message, fcmData);
            
            if (messageId != null) {
                log.info("Notification sent successfully to user: {}, messageId: {}", userId, messageId);
            } else {
                log.warn("FCM notification not sent (FCM may be disabled or user has no token)");
            }
        } catch (Exception e) {
            log.error("Failed to send notification to user: {}", userId, e);
            // Don't throw exception - notification failure shouldn't break the flow
        }
    }
}
