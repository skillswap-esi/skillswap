package com.skillswap.mission.events;

import com.skillswap.mission.enums.MissionEventType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MissionEvent {
    private UUID missionId;
    private UUID skillId;
    private String requesterId;
    private String providerId;
    private MissionEventType eventType;
    private String missionTitle;
    private Integer creditAmount;
    private Date timestamp;
    private Map<String, Object> metadata;
}
