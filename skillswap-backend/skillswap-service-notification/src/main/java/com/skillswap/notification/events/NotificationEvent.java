package com.skillswap.notification.events;

import java.util.Date;
import java.util.Map;
import java.util.UUID;

public record NotificationEvent(
    UUID eventId,
    NotificationType type,
    Map<String, Object> payload,
    Date createdAt
) {}
