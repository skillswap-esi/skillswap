package com.skillswap.skill.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreatePartnerPlaceRequest(
    @NotBlank String name,
    @NotBlank String address,
    @NotNull Double lat,
    @NotNull Double lng
) {}
