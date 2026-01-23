package com.skillswap.mission.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkillDto {
    private UUID skillId;
    private UUID ownerId;
    private String title;
    private String description;
    private String category;
    private Double latitude;
    private Double longitude;
    private Boolean active;
}
