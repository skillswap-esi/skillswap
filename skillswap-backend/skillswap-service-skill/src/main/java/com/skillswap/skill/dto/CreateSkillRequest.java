package com.skillswap.skill.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateSkillRequest(
    @NotBlank String title,
    @NotBlank String category,
    @NotBlank String description,
    @NotNull Double lat,
    @NotNull Double lng
) {}
