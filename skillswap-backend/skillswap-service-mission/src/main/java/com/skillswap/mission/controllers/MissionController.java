package com.skillswap.mission.controllers;

import com.skillswap.mission.dto.*;
import com.skillswap.mission.enums.MissionStatus;
import com.skillswap.mission.services.MissionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/missions")
@RequiredArgsConstructor
@Slf4j
public class MissionController {
    
    private final MissionService missionService;
    
    @PostMapping
    public ResponseEntity<MissionResponse> createMission(
            @Valid @RequestBody CreateMissionRequest request,
            @RequestHeader("X-User-Id") UUID requesterId) {
        log.info("POST /api/missions - Creating mission for requester: {}", requesterId);
        MissionResponse response = missionService.createMission(request, requesterId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @GetMapping("/{missionId}")
    public ResponseEntity<MissionResponse> getMissionById(@PathVariable UUID missionId) {
        log.info("GET /api/missions/{} - Getting mission", missionId);
        MissionResponse response = missionService.getMissionById(missionId);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<MissionResponse>> getUserMissions(
            @PathVariable UUID userId,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) MissionStatus status) {
        log.info("GET /api/missions/user/{} - Getting missions (role: {}, status: {})", 
                userId, role, status);
        List<MissionResponse> missions = missionService.getUserMissions(userId, role, status);
        return ResponseEntity.ok(missions);
    }
    
    @PostMapping("/{missionId}/accept")
    public ResponseEntity<MissionResponse> acceptMission(
            @PathVariable UUID missionId,
            @RequestHeader("X-User-Id") UUID helperId) {
        log.info("POST /api/missions/{}/accept - Helper {} accepting mission", missionId, helperId);
        MissionResponse response = missionService.acceptMission(missionId, helperId);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/{missionId}/reject")
    public ResponseEntity<Void> rejectMission(
            @PathVariable UUID missionId,
            @RequestHeader("X-User-Id") UUID helperId,
            @Valid @RequestBody CancelMissionRequest request) {
        log.info("POST /api/missions/{}/reject - Helper {} rejecting mission", missionId, helperId);
        missionService.rejectMission(missionId, helperId, request.getReason());
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{missionId}/cancel")
    public ResponseEntity<Void> cancelMission(
            @PathVariable UUID missionId,
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CancelMissionRequest request) {
        log.info("POST /api/missions/{}/cancel - User {} cancelling mission", missionId, userId);
        missionService.cancelMission(missionId, userId, request.getReason());
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{missionId}/start")
    public ResponseEntity<MissionResponse> startMission(
            @PathVariable UUID missionId,
            @RequestHeader("X-User-Id") UUID userId) {
        log.info("POST /api/missions/{}/start - User {} starting mission", missionId, userId);
        MissionResponse response = missionService.startMission(missionId, userId);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/{missionId}/generate-otp")
    public ResponseEntity<OtpResponse> generateOtp(
            @PathVariable UUID missionId,
            @RequestHeader("X-User-Id") UUID helperId) {
        log.info("POST /api/missions/{}/generate-otp - Helper {} generating OTP", missionId, helperId);
        OtpResponse response = missionService.generateOtp(missionId, helperId);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/{missionId}/validate-otp")
    public ResponseEntity<MissionResponse> validateOtp(
            @PathVariable UUID missionId,
            @RequestHeader("X-User-Id") UUID requesterId,
            @Valid @RequestBody ValidateOtpRequest request) {
        log.info("POST /api/missions/{}/validate-otp - Requester {} validating OTP", 
                missionId, requesterId);
        MissionResponse response = missionService.validateOtp(missionId, requesterId, request.getOtpCode());
        return ResponseEntity.ok(response);
    }
}
