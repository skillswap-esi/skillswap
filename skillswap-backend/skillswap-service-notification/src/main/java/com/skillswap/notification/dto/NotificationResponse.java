package com.skillswap.notification.dto;

import com.skillswap.notification.enums.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private UUID notificationId;
    private UUID userId;
    private NotificationType type;
    private String title;
    private String message;
    private Map<String, Object> data;
    private boolean read;
    private Date sentAt;
    private Date readAt;
}
