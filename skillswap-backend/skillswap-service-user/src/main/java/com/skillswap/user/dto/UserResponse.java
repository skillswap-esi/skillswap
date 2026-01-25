package com.skillswap.user.dto;

import java.util.List;
import java.util.UUID;

public record UserResponse(
    UUID userId,
    String fullName,
    String email,
    String phoneNumber,
    float helperScore,
    int creditsBalance,
    String avatar,
    List<String> roles
) {}
