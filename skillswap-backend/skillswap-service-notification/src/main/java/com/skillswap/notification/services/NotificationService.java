package com.skillswap.notification.services;

import com.skillswap.notification.dto.NotificationResponse;
import com.skillswap.notification.enums.NotificationType;
import com.skillswap.notification.model.Notification;
import com.skillswap.notification.repositories.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    
    private final NotificationRepository notificationRepository;
    private final FcmService fcmService;
    
    public NotificationResponse createNotification(
            UUID userId,
            NotificationType type,
            String title,
            String message,
            Map<String, Object> data) {
        
        log.info("Creating notification for user: {}, type: {}", userId, type);
        
        Notification notification = Notification.builder()
                .notificationId(UUID.randomUUID())
                .userId(userId)
                .type(type)
                .title(title)
                .message(message)
                .data(data)
                .read(false)
                .build();
        
        Notification saved = notificationRepository.save(notification);
        
        // Send FCM notification
        Map<String, String> fcmData = new HashMap<>();
        fcmData.put("notificationId", saved.getNotificationId().toString());
        fcmData.put("type", type.toString());
        if (data != null) {
            data.forEach((key, value) -> fcmData.put(key, value.toString()));
        }
        
        String fcmMessageId = fcmService.sendNotification(userId, title, message, fcmData);
        
        if (fcmMessageId != null) {
            saved.setFcmSent(true);
            saved.setFcmMessageId(fcmMessageId);
            saved = notificationRepository.save(saved);
        }
        
        return mapToResponse(saved);
    }
    
    public List<NotificationResponse> getUserNotifications(UUID userId) {
        log.info("Getting notifications for user: {}", userId);
        return notificationRepository.findByUserIdOrderBySentAtDesc(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<NotificationResponse> getUnreadNotifications(UUID userId) {
        log.info("Getting unread notifications for user: {}", userId);
        return notificationRepository.findByUserIdAndReadOrderBySentAtDesc(userId, false)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public long getUnreadCount(UUID userId) {
        return notificationRepository.countByUserIdAndRead(userId, false);
    }
    
    public void markAsRead(UUID notificationId, UUID userId) {
        log.info("Marking notification {} as read for user: {}", notificationId, userId);
        
        notificationRepository.findById(notificationId).ifPresent(notification -> {
            if (notification.getUserId().equals(userId)) {
                notification.setRead(true);
                notification.setReadAt(new Date());
                notificationRepository.save(notification);
            }
        });
    }
    
    public void markAllAsRead(UUID userId) {
        log.info("Marking all notifications as read for user: {}", userId);
        
        List<Notification> unread = notificationRepository.findByUserIdAndReadOrderBySentAtDesc(userId, false);
        unread.forEach(notification -> {
            notification.setRead(true);
            notification.setReadAt(new Date());
        });
        
        notificationRepository.saveAll(unread);
    }
    
    public void deleteNotification(UUID notificationId, UUID userId) {
        log.info("Deleting notification {} for user: {}", notificationId, userId);
        
        notificationRepository.findById(notificationId).ifPresent(notification -> {
            if (notification.getUserId().equals(userId)) {
                notificationRepository.delete(notification);
            }
        });
    }
    
    private NotificationResponse mapToResponse(Notification notification) {
        return NotificationResponse.builder()
                .notificationId(notification.getNotificationId())
                .userId(notification.getUserId())
                .type(notification.getType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .data(notification.getData())
                .read(notification.isRead())
                .sentAt(notification.getSentAt())
                .readAt(notification.getReadAt())
                .build();
    }
}
