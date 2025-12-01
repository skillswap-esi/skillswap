package com.skillswap.skill.dto;

public record UpdateSkillRequest(
    String title,
    String category,
    String description,
    Boolean active
) {}
