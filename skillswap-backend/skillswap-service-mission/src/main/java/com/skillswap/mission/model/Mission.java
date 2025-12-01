package com.skillswap.mission.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document("missions")
public class Mission {
    
    @Id
    private UUID missionId;
    
    private UUID requesterId;
    private UUID providerId;
    private UUID skillId;
    
    @Indexed
    private MissionStatus status;
    
    private MeetingPoint meetingPoint;
    private String generatedOtp; // hashé
    private Date otpExpiresAt;
    private Date createdAt;
    private Date updatedAt;
    private Date completedAt;
}
