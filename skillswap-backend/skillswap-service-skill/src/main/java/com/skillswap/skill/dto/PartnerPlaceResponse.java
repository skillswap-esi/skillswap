package com.skillswap.skill.dto;

import java.util.Date;
import java.util.UUID;

public record PartnerPlaceResponse(
    UUID placeId,
    String name,
    String address,
    double lat,
    double lng,
    UUID addedBy,
    Date createdAt
) {}
