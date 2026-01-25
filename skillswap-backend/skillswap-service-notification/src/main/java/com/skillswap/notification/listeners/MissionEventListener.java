package com.skillswap.notification.listeners;

import com.skillswap.notification.enums.NotificationType;
import com.skillswap.notification.events.MissionEvent;
import com.skillswap.notification.services.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class MissionEventListener {
    
    private final NotificationService notificationService;
    
    @KafkaListener(
        topics = "${kafka.topics.mission-events}",
        groupId = "${spring.kafka.consumer.group-id}"
    )
    public void handleMissionEvent(
            @Payload MissionEvent event,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset) {
        
        log.info("Received event: {} for mission: {} from partition: {} offset: {}", 
                event.getEventType(), event.getMissionId(), partition, offset);
        
        try {
            switch (event.getEventType()) {
                case MISSION_CREATED:
                    handleMissionCreated(event);
                    break;
                case MISSION_ACCEPTED:
                    handleMissionAccepted(event);
                    break;
                case MISSION_REJECTED:
                    handleMissionRejected(event);
                    break;
                case MISSION_STARTED:
                    handleMissionStarted(event);
                    break;
                case MISSION_COMPLETED:
                    handleMissionCompleted(event);
                    break;
                case MISSION_CANCELLED:
                    handleMissionCancelled(event);
                    break;
                default:
                    log.warn("Unknown event type: {}", event.getEventType());
            }
        } catch (Exception e) {
            log.error("Error processing event: {}", event.getEventType(), e);
        }
    }
    
    private void handleMissionCreated(MissionEvent event) {
        // Get skill owner ID from metadata
        String skillOwnerId = null;
        if (event.getMetadata() != null && event.getMetadata().containsKey("skillOwnerId")) {
            skillOwnerId = (String) event.getMetadata().get("skillOwnerId");
        }
        
        if (skillOwnerId == null) {
            log.warn("Mission created event has no skillOwnerId in metadata, cannot send notification");
            return;
        }
        
        Map<String, Object> data = new HashMap<>();
        data.put("missionId", event.getMissionId().toString());
        data.put("skillId", event.getSkillId().toString());
        data.put("requesterId", event.getRequesterId());
        
        try {
            notificationService.sendNotification(
                    UUID.fromString(skillOwnerId),
                    NotificationType.MISSION_CREATED,
                    "New Mission Request",
                    "Someone wants to learn: " + event.getMissionTitle(),
                    data
            );
        } catch (IllegalArgumentException e) {
            log.error("Invalid UUID format for skillOwnerId: {}", skillOwnerId, e);
        }
    }
    
    private void handleMissionAccepted(MissionEvent event) {
        Map<String, Object> data = new HashMap<>();
        data.put("missionId", event.getMissionId().toString());
        
        notificationService.sendNotification(
                event.getRequesterId(),
                NotificationType.MISSION_ACCEPTED,
                "Mission Accepted!",
                "Your mission \"" + event.getMissionTitle() + "\" has been accepted",
                data
        );
    }
    
    private void handleMissionRejected(MissionEvent event) {
        Map<String, Object> data = new HashMap<>();
        data.put("missionId", event.getMissionId().toString());
        
        String reason = event.getMetadata() != null 
                ? (String) event.getMetadata().get("reason") 
                : "No reason provided";
        
        notificationService.sendNotification(
                event.getRequesterId(),
                NotificationType.MISSION_REJECTED,
                "Mission Rejected",
                "Your mission \"" + event.getMissionTitle() + "\" was rejected. Reason: " + reason,
                data
        );
    }
    
    private void handleMissionStarted(MissionEvent event) {
        Map<String, Object> data = new HashMap<>();
        data.put("missionId", event.getMissionId().toString());
        
        // Notify both requester and helper
        notificationService.sendNotification(
                event.getRequesterId(),
                NotificationType.MISSION_STARTED,
                "Mission Started",
                "Your mission \"" + event.getMissionTitle() + "\" has started",
                data
        );
        
        if (event.getProviderId() != null) {
            notificationService.sendNotification(
                    event.getProviderId(),
                    NotificationType.MISSION_STARTED,
                    "Mission Started",
                    "Mission \"" + event.getMissionTitle() + "\" has started",
                    data
            );
        }
    }
    
    private void handleMissionCompleted(MissionEvent event) {
        Map<String, Object> data = new HashMap<>();
        data.put("missionId", event.getMissionId().toString());
        data.put("credits", event.getCreditAmount().toString());
        
        // Notify requester
        notificationService.sendNotification(
                event.getRequesterId(),
                NotificationType.MISSION_COMPLETED,
                "Mission Completed!",
                "Mission \"" + event.getMissionTitle() + "\" completed successfully",
                data
        );
        
        // Notify provider about credits received
        if (event.getProviderId() != null) {
            notificationService.sendNotification(
                    event.getProviderId(),
                    NotificationType.CREDIT_RECEIVED,
                    "Credits Received!",
                    "You earned " + event.getCreditAmount() + " credits for completing \"" + event.getMissionTitle() + "\"",
                    data
            );
        }
    }
    
    private void handleMissionCancelled(MissionEvent event) {
        Map<String, Object> data = new HashMap<>();
        data.put("missionId", event.getMissionId().toString());
        
        String reason = event.getMetadata() != null 
                ? (String) event.getMetadata().get("reason") 
                : "No reason provided";
        
        // Notify both parties
        notificationService.sendNotification(
                event.getRequesterId(),
                NotificationType.MISSION_CANCELLED,
                "Mission Cancelled",
                "Mission \"" + event.getMissionTitle() + "\" was cancelled. Reason: " + reason,
                data
        );
        
        if (event.getProviderId() != null) {
            notificationService.sendNotification(
                    event.getProviderId(),
                    NotificationType.MISSION_CANCELLED,
                    "Mission Cancelled",
                    "Mission \"" + event.getMissionTitle() + "\" was cancelled. Reason: " + reason,
                    data
            );
        }
    }
}
