package com.skillswap.mission.exceptions;

public class UnauthorizedMissionAccessException extends RuntimeException {
    public UnauthorizedMissionAccessException(String message) {
        super(message);
    }
}
