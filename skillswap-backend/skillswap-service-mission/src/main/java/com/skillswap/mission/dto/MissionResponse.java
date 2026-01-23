package com.skillswap.mission.dto;

import com.skillswap.mission.enums.MissionStatus;
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
public class MissionResponse {
    
    private UUID missionId;
    private UUID skillId;
    private String skillTitle;
    private String skillCategory;
    
    private UUID requesterId;
    private String requesterName;
    private String requesterAvatar;
    
    private UUID helperId;
    private String helperName;
    private String helperAvatar;
    private Integer helperScore;
    
    private String title;
    private String description;
    private MissionStatus status;
    
    private Date scheduledDate;
    private Integer duration;
    private Integer creditCost;
    
    private Double latitude;
    private Double longitude;
    private String location;
    
    private Date createdAt;
    private Date updatedAt;
    private Date acceptedAt;
    private Date startedAt;
    private Date completedAt;
    private Date cancelledAt;
    
    private String cancellationReason;
    private String rejectionReason;
}
