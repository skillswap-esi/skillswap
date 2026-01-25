package com.skillswap.mission.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateMissionRequest {
    
    @NotNull(message = "Skill ID is required")
    private UUID skillId;
    
    @NotBlank(message = "Title is required")
    @Size(min = 3, max = 100, message = "Title must be between 3 and 100 characters")
    private String title;
    
    @NotBlank(message = "Description is required")
    @Size(min = 10, max = 500, message = "Description must be between 10 and 500 characters")
    private String description;
    
    @NotNull(message = "Scheduled date is required")
    @Future(message = "Scheduled date must be in the future")
    private Date scheduledDate;
    
    @NotNull(message = "Duration is required")
    @Min(value = 15, message = "Duration must be at least 15 minutes")
    @Max(value = 480, message = "Duration cannot exceed 8 hours")
    private Integer duration;
    
    @NotNull(message = "Credit cost is required")
    @Min(value = 1, message = "Credit cost must be at least 1")
    @Max(value = 100, message = "Credit cost cannot exceed 100")
    private Integer creditCost;
}
