package com.skillswap.notification.model;

import com.skillswap.notification.enums.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document("notifications")
public class Notification {
    
    @Id
    private UUID notificationId;
    
    @Indexed
    private UUID userId;  // Recipient
    
    @Indexed
    private NotificationType type;
    
    private String title;
    private String message;
    private Map<String, Object> data;
    
    @Indexed
    private boolean read;
    
    @CreatedDate
    private Date sentAt;
    
    private Date readAt;
    
    private boolean fcmSent;
    private String fcmMessageId;
}
