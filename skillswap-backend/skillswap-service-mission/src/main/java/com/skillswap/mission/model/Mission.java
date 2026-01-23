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
    private UUID requesterId;  // Person requesting help
    
    @Indexed
    private UUID helperId;     // Person providing help (null until accepted)
    
    private String title;
    private String description;
    
    @Indexed
    private MissionStatus status;
    
    private Date scheduledDate;
    private Integer duration;      // Duration in minutes
    private Integer creditCost;
    
    // Location (copied from skill for convenience)
    private GeoJsonPoint geoPoint;
    private String location;
    
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
}
