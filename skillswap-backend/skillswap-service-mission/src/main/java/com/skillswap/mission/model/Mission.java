package com.skillswap.mission.model;

import com.skillswap.mission.enums.MissionStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.geo.GeoJsonPoint;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document("missions")
public class Mission {
    
    @Id
    private UUID missionId;
    
    @Indexed
    private UUID skillId;
    
    @Indexed
    private String requesterId;  // Demandeur - Person requesting help
    
    @Indexed
    private String providerId;   // Prestataire - Person providing help (null until accepted)
    
    private String title;
    private String description;
    
    @Indexed
    private MissionStatus status;
    
    private Date scheduledDate;
    private Integer duration;      // Duration in minutes
    private Integer creditCost;
    
    // Meeting point for the mission (lieu public)
    private MeetingPoint meetingPoint;
    
    // OTP for mission validation
    private String generatedOtp;
    private Date otpExpiresAt;
    
    @CreatedDate
    private Date createdAt;
    
    @LastModifiedDate
    private Date updatedAt;
    
    private Date acceptedAt;
    private Date startedAt;
    private Date completedAt;
    private Date cancelledAt;
    
    private String cancellationReason;
    private String rejectionReason;
    
    // Inner class for meeting point
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MeetingPoint {
        private Double lat;
        private Double lng;
        private UUID partnerPlaceId;  // Reference to PartnerPlace if selected
    }
}
