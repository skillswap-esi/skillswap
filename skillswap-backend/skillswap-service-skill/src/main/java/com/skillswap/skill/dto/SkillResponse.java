package com.skillswap.skill.dto;

import java.util.Date;
import java.util.UUID;

public record SkillResponse(
    UUID skillId,
    UUID ownerId,
    String title,
    String category,
    String description,
    double lat,
    double lng,
    boolean active,
    Date createdAt
) {}
