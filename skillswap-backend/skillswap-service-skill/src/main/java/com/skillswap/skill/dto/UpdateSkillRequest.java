package com.skillswap.skill.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateSkillRequest {
    private String title;
    private String description;
    private String category;
    private Double latitude;
    private Double longitude;
    private Boolean active;
}
