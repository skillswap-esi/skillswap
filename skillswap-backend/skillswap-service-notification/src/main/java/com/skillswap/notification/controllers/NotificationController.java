package com.skillswap.notification.controllers;

import com.skillswap.notification.dto.NotificationResponse;
import com.skillswap.notification.dto.RegisterTokenRequest;
import com.skillswap.notification.services.FcmService;
import com.skillswap.notification.services.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@Slf4j
public class NotificationController {
    
    private final NotificationService notificationService;
    private final FcmService fcmService;
    
    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getUserNotifications(
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("GET /api/notifications - Getting notifications for user: {}", userId);
        List<NotificationResponse> notifications = notificationService.getUserNotifications(userId);
        return ResponseEntity.ok(notifications);
    }
    
    @GetMapping("/unread")
    public ResponseEntity<List<NotificationResponse>> getUnreadNotifications(
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("GET /api/notifications/unread - Getting unread notifications for user: {}", userId);
        List<NotificationResponse> notifications = notificationService.getUnreadNotifications(userId);
        return ResponseEntity.ok(notifications);
    }
    
    @GetMapping("/unread/count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("GET /api/notifications/unread/count - Getting unread count for user: {}", userId);
        long count = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(Map.of("count", count));
    }
    
    @PostMapping("/{notificationId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable UUID notificationId,
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("POST /api/notifications/{}/read - Marking as read for user: {}", notificationId, userId);
        notificationService.markAsRead(notificationId, userId);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("POST /api/notifications/read-all - Marking all as read for user: {}", userId);
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok().build();
    }
    
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Void> deleteNotification(
            @PathVariable UUID notificationId,
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("DELETE /api/notifications/{} - Deleting for user: {}", notificationId, userId);
        notificationService.deleteNotification(notificationId, userId);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/token")
    public ResponseEntity<Void> registerFcmToken(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody RegisterTokenRequest request) {
        log.info("POST /api/notifications/token - Registering FCM token for user: {}", userId);
        fcmService.registerToken(userId, request.getToken(), request.getDeviceType());
        return ResponseEntity.ok().build();
    }
    
    @DeleteMapping("/token")
    public ResponseEntity<Void> unregisterFcmToken(
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("DELETE /api/notifications/token - Unregistering FCM token for user: {}", userId);
        fcmService.unregisterToken(userId);
        return ResponseEntity.ok().build();
    }
}
