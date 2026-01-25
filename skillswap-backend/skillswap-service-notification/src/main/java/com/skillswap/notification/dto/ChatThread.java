package com.skillswap.notification.dto;

import java.util.Date;
import java.util.List;
import java.util.UUID;

public record ChatThread(
    UUID threadId,
    List<UUID> userIds,
    String lastMessage,
    Date updatedAt
) {}
