package com.skillswap.mission.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateMissionRequest(
    @NotNull UUID skillId,
    @NotNull UUID providerId,
    @NotNull Double lat,
    @NotNull Double lng,
    UUID partnerPlaceId
) {}
