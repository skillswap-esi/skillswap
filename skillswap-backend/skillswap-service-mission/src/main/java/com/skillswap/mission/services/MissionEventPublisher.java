package com.skillswap.mission.services;

import com.skillswap.mission.enums.MissionEventType;
import com.skillswap.mission.events.MissionEvent;
import com.skillswap.mission.model.Mission;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
@RequiredArgsConstructor
@Slf4j
public class MissionEventPublisher {
    
    private final KafkaTemplate<String, MissionEvent> kafkaTemplate;
    
    @Value("${kafka.topics.mission-events}")
    private String missionEventsTopic;
    
    public void publishMissionCreated(Mission mission, String skillOwnerId) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_CREATED);
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("skillOwnerId", skillOwnerId);
        event.setMetadata(metadata);
        publishEvent(event);
    }
    
    public void publishMissionAccepted(Mission mission) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_ACCEPTED);
        publishEvent(event);
    }
    
    public void publishMissionRejected(Mission mission, String reason) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_REJECTED);
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("reason", reason);
        event.setMetadata(metadata);
        publishEvent(event);
    }
    
    public void publishMissionStarted(Mission mission) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_STARTED);
        publishEvent(event);
    }
    
    public void publishMissionCompleted(Mission mission) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_COMPLETED);
        publishEvent(event);
    }
    
    public void publishMissionCancelled(Mission mission, String reason) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_CANCELLED);
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("reason", reason);
        event.setMetadata(metadata);
        publishEvent(event);
    }
    
    private MissionEvent buildEvent(Mission mission, MissionEventType eventType) {
        return MissionEvent.builder()
                .missionId(mission.getMissionId())
                .skillId(mission.getSkillId())
                .requesterId(mission.getRequesterId())
                .providerId(mission.getProviderId())
                .eventType(eventType)
                .missionTitle(mission.getTitle())
                .creditAmount(mission.getCreditCost())
                .timestamp(new Date())
                .build();
    }
    
    private void publishEvent(MissionEvent event) {
        log.info("Publishing event: {} for mission: {}", 
                event.getEventType(), event.getMissionId());
        
        CompletableFuture<SendResult<String, MissionEvent>> future = 
                kafkaTemplate.send(missionEventsTopic, event.getMissionId().toString(), event);
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                log.info("Event published successfully: {} to partition: {}", 
                        event.getEventType(), result.getRecordMetadata().partition());
            } else {
                log.error("Failed to publish event: {}", event.getEventType(), ex);
            }
        });
    }
}
