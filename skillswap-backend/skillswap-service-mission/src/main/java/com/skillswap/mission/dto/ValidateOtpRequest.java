package com.skillswap.mission.dto;

import jakarta.validation.constraints.Size;

public record ValidateOtpRequest(
    @Size(min = 4, max = 6) String otpCode
) {}
