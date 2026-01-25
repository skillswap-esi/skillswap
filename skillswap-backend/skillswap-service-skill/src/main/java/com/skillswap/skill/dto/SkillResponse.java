package com.skillswap.skill.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkillResponse {
    private UUID skillId;
    private String ownerId;
    private String title;
    private String description;
    private String category;
    private Double latitude;
    private Double longitude;
    private boolean active;
    private Date createdAt;
    private Date updatedAt;
    private Double distance; // Distance in km (for search results)
    
    // Owner information (optional, enriched from User service)
    private String ownerName;
    private Float ownerScore;
    private String ownerAvatar;
}
