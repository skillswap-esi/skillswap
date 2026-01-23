package com.skillswap.mission.enums;

public enum MissionStatus {
    PENDING,      // Waiting for helper to accept
    ACCEPTED,     // Helper accepted the mission
    IN_PROGRESS,  // Mission is currently happening
    COMPLETED,    // Mission completed successfully
    CANCELLED,    // Mission was cancelled
    REJECTED      // Helper rejected the mission
}
