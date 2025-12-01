package com.skillswap.mission.dto;

import com.skillswap.mission.model.MissionStatus;

import java.util.Date;
import java.util.UUID;

public record MissionResponse(
    UUID missionId,
    UUID requesterId,
    UUID providerId,
    UUID skillId,
    MissionStatus status,
    double lat,
    double lng,
    UUID partnerPlaceId,
    Date createdAt,
    Date updatedAt,
    Date completedAt
) {}
