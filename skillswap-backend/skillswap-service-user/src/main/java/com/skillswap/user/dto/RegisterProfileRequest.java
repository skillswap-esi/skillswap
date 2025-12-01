package com.skillswap.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record RegisterProfileRequest(
    @NotBlank String fullName,
    @Email String email,
    @NotBlank String phoneNumber
) {}
