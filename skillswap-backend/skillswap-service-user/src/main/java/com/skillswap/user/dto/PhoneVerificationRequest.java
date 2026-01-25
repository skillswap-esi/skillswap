package com.skillswap.user.dto;

import jakarta.validation.constraints.Size;

public record PhoneVerificationRequest(
    @Size(min = 4, max = 6) String otpCode
) {}
