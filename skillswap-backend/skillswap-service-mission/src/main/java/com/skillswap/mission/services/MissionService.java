package com.skillswap.mission.services;

import com.skillswap.mission.client.SkillClient;
import com.skillswap.mission.client.UserClient;
import com.skillswap.mission.dto.*;
import com.skillswap.mission.enums.MissionStatus;
import com.skillswap.mission.exceptions.*;
import com.skillswap.mission.model.Mission;
import com.skillswap.mission.repositories.MissionRepository;
import feign.FeignException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.mongodb.core.geo.GeoJsonPoint;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MissionService {
    
    private final MissionRepository missionRepository;
    private final UserClient userClient;
    private final SkillClient skillClient;
    private final OtpService otpService;
    private final MissionEventPublisher eventPublisher;
    
    @Value("${mission.enrich-with-user-data:false}")
    private boolean enrichWithUserData;
    
    @Transactional
    public MissionResponse createMission(CreateMissionRequest request, String requesterId) {
        log.info("Creating mission for requester: {}", requesterId);
        
        // 1. Verify skill exists and is active
        SkillDto skill;
        try {
            skill = skillClient.getSkillById(request.getSkillId());
            if (!skill.getActive()) {
                throw new SkillNotFoundException("Skill is not active");
            }
        } catch (FeignException.NotFound e) {
            throw new SkillNotFoundException("Skill not found with ID: " + request.getSkillId());
        }
        
        // 2. Verify requester has sufficient credits
        UserDto requester;
        try {
            requester = userClient.getUserById(requesterId);
            if (requester.getCreditsBalance() < request.getCreditCost()) {
                throw new InsufficientCreditsException(
                    String.format("Insufficient credits. Required: %d, Available: %d", 
                        request.getCreditCost(), requester.getCreditsBalance())
                );
            }
        } catch (FeignException.NotFound e) {
            throw new RuntimeException("Requester not found");
        }
        
        // 3. Debit credits from requester
        try {
            userClient.debitCredits(requesterId, request.getCreditCost());
        } catch (Exception e) {
            log.error("Failed to debit credits from requester: {}", requesterId, e);
            throw new RuntimeException("Failed to process credit transaction");
        }
        
        // 4. Create mission
        Mission mission = new Mission();
        mission.setMissionId(UUID.randomUUID());
        mission.setSkillId(request.getSkillId());
        mission.setRequesterId(requesterId);
        mission.setTitle(request.getTitle());
        mission.setDescription(request.getDescription());
        mission.setScheduledDate(request.getScheduledDate());
        mission.setDuration(request.getDuration());
        mission.setCreditCost(request.getCreditCost());
        mission.setStatus(MissionStatus.PENDING);
        
        Mission savedMission = missionRepository.save(mission);
        log.info("Mission created successfully with ID: {}", savedMission.getMissionId());
        
        // 5. Publish event with skill owner ID
        eventPublisher.publishMissionCreated(savedMission, skill.getOwnerId().toString());
        
        return mapToResponse(savedMission, skill, enrichWithUserData);
    }
    
    public MissionResponse getMissionById(UUID missionId) {
        log.info("Getting mission by ID: {}", missionId);
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        SkillDto skill = null;
        try {
            skill = skillClient.getSkillById(mission.getSkillId());
        } catch (Exception e) {
            log.warn("Failed to fetch skill for mission: {}", missionId);
        }
        
        return mapToResponse(mission, skill, enrichWithUserData);
    }
    
    public List<MissionResponse> getUserMissions(String userId, String role, MissionStatus status) {
        log.info("Getting missions for user: {}, role: {}, status: {}", userId, role, status);
        
        List<Mission> missions;
        
        if (role != null && role.equalsIgnoreCase("REQUESTER")) {
            missions = status != null 
                ? missionRepository.findByRequesterIdAndStatus(userId, status)
                : missionRepository.findByRequesterId(userId);
        } else if (role != null && role.equalsIgnoreCase("HELPER")) {
            // Get missions where user is provider (accepted missions)
            missions = status != null
                ? missionRepository.findByProviderIdAndStatus(userId, status)
                : missionRepository.findByProviderId(userId);
            
            // Also get PENDING missions for skills owned by this user
            try {
                List<SkillDto> userSkills = skillClient.getSkillsByOwner(userId);
                List<UUID> skillIds = userSkills.stream()
                        .map(SkillDto::getSkillId)
                        .collect(Collectors.toList());
                
                // Get all PENDING missions for these skills
                for (UUID skillId : skillIds) {
                    List<Mission> pendingMissions = missionRepository.findBySkillIdAndStatus(skillId, MissionStatus.PENDING);
                    missions.addAll(pendingMissions);
                }
            } catch (Exception e) {
                log.warn("Failed to fetch skills for user: {}", userId, e);
            }
            
            // Filter by status if specified
            if (status != null) {
                missions = missions.stream()
                        .filter(m -> m.getStatus() == status)
                        .distinct()
                        .collect(Collectors.toList());
            } else {
                missions = missions.stream().distinct().collect(Collectors.toList());
            }
        } else {
            // Get all missions where user is either requester or provider
            List<Mission> asRequester = missionRepository.findByRequesterId(userId);
            List<Mission> asProvider = missionRepository.findByProviderId(userId);
            missions = asRequester;
            missions.addAll(asProvider);
            
            if (status != null) {
                missions = missions.stream()
                        .filter(m -> m.getStatus() == status)
                        .collect(Collectors.toList());
            }
        }
        
        return missions.stream()
                .map(mission -> {
                    SkillDto skill = null;
                    try {
                        skill = skillClient.getSkillById(mission.getSkillId());
                    } catch (Exception e) {
                        log.warn("Failed to fetch skill for mission: {}", mission.getMissionId());
                    }
                    return mapToResponse(mission, skill, false);
                })
                .collect(Collectors.toList());
    }
    
    @Transactional
    public MissionResponse acceptMission(UUID missionId, String providerId) {
        log.info("Provider {} accepting mission: {}", providerId, missionId);
        
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        // Verify mission status
        if (mission.getStatus() != MissionStatus.PENDING) {
            throw new InvalidMissionStatusException("Mission is not in PENDING status");
        }
        
        // Verify provider is the skill owner
        SkillDto skill;
        try {
            skill = skillClient.getSkillById(mission.getSkillId());
            log.info("Skill found: {} owned by: {}", skill.getSkillId(), skill.getOwnerId());
            log.info("Provider attempting to accept: {}", providerId);
            
            if (!skill.getOwnerId().equals(providerId)) {
                log.warn("Ownership mismatch - Skill owner: {}, Provider: {}", skill.getOwnerId(), providerId);
                throw new UnauthorizedMissionAccessException("Only the skill owner can accept this mission");
            }
        } catch (FeignException.NotFound e) {
            log.error("Skill not found with ID: {}", mission.getSkillId());
            throw new SkillNotFoundException("Skill not found with ID: " + mission.getSkillId());
        } catch (FeignException e) {
            log.error("Error fetching skill: {}", e.getMessage());
            throw new SkillNotFoundException("Error fetching skill: " + e.getMessage());
        }
        
        // Update mission
        mission.setProviderId(providerId);
        mission.setStatus(MissionStatus.ACCEPTED);
        mission.setAcceptedAt(new Date());
        
        Mission updated = missionRepository.save(mission);
        log.info("Mission accepted successfully");
        
        // Publish event
        eventPublisher.publishMissionAccepted(updated);
        
        return mapToResponse(updated, skill, enrichWithUserData);
    }
    
    @Transactional
    public void rejectMission(UUID missionId, String providerId, String reason) {
        log.info("Provider {} rejecting mission: {}", providerId, missionId);
        
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        // Verify mission status
        if (mission.getStatus() != MissionStatus.PENDING) {
            throw new InvalidMissionStatusException("Mission is not in PENDING status");
        }
        
        // Verify provider is the skill owner
        try {
            SkillDto skill = skillClient.getSkillById(mission.getSkillId());
            if (!skill.getOwnerId().equals(providerId)) {
                throw new UnauthorizedMissionAccessException("Only the skill owner can reject this mission");
            }
        } catch (FeignException.NotFound e) {
            throw new SkillNotFoundException("Skill not found");
        }
        
        // Refund credits to requester
        try {
            userClient.creditCredits(mission.getRequesterId(), mission.getCreditCost());
        } catch (Exception e) {
            log.error("Failed to refund credits to requester: {}", mission.getRequesterId(), e);
        }
        
        // Update mission
        mission.setStatus(MissionStatus.REJECTED);
        mission.setRejectionReason(reason);
        
        missionRepository.save(mission);
        log.info("Mission rejected successfully");
        
        // Publish event
        eventPublisher.publishMissionRejected(mission, reason);
    }
    
    @Transactional
    public void cancelMission(UUID missionId, String userId, String reason) {
        log.info("User {} cancelling mission: {}", userId, missionId);
        
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        // Verify user is requester or provider
        if (!mission.getRequesterId().equals(userId) && 
            (mission.getProviderId() == null || !mission.getProviderId().equals(userId))) {
            throw new UnauthorizedMissionAccessException("Only requester or provider can cancel this mission");
        }
        
        // Cannot cancel completed missions
        if (mission.getStatus() == MissionStatus.COMPLETED) {
            throw new InvalidMissionStatusException("Cannot cancel a completed mission");
        }
        
        // Refund credits if mission not started
        if (mission.getStatus() == MissionStatus.PENDING || mission.getStatus() == MissionStatus.ACCEPTED) {
            try {
                userClient.creditCredits(mission.getRequesterId(), mission.getCreditCost());
            } catch (Exception e) {
                log.error("Failed to refund credits to requester: {}", mission.getRequesterId(), e);
            }
        }
        
        // Delete OTP if exists
        otpService.deleteOtp(missionId);
        
        // Update mission
        mission.setStatus(MissionStatus.CANCELLED);
        mission.setCancellationReason(reason);
        mission.setCancelledAt(new Date());
        
        missionRepository.save(mission);
        log.info("Mission cancelled successfully");
        
        // Publish event
        eventPublisher.publishMissionCancelled(mission, reason);
    }
    
    @Transactional
    public MissionResponse startMission(UUID missionId, String userId) {
        log.info("User {} starting mission: {}", userId, missionId);
        
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        // Verify user is requester or provider
        if (!mission.getRequesterId().equals(userId) && !mission.getProviderId().equals(userId)) {
            throw new UnauthorizedMissionAccessException("Only requester or provider can start this mission");
        }
        
        // Verify mission status
        if (mission.getStatus() != MissionStatus.ACCEPTED) {
            throw new InvalidMissionStatusException("Mission must be in ACCEPTED status to start");
        }
        
        // Update mission
        mission.setStatus(MissionStatus.IN_PROGRESS);
        mission.setStartedAt(new Date());
        
        Mission updated = missionRepository.save(mission);
        log.info("Mission started successfully");
        
        // Publish event
        eventPublisher.publishMissionStarted(updated);
        
        SkillDto skill = null;
        try {
            skill = skillClient.getSkillById(mission.getSkillId());
        } catch (Exception e) {
            log.warn("Failed to fetch skill");
        }
        
        return mapToResponse(updated, skill, enrichWithUserData);
    }
    
    public OtpResponse generateOtp(UUID missionId, String providerId) {
        log.info("Provider {} generating OTP for mission: {}", providerId, missionId);
        
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        // Verify user is provider
        if (!mission.getProviderId().equals(providerId)) {
            throw new UnauthorizedMissionAccessException("Only the provider can generate OTP");
        }
        
        // Verify mission status
        if (mission.getStatus() != MissionStatus.IN_PROGRESS) {
            throw new InvalidMissionStatusException("Mission must be IN_PROGRESS to generate OTP");
        }
        
        String otp = otpService.generateOtp(missionId);
        
        return OtpResponse.builder()
                .otpCode(otp)
                .expiresIn(5 * 60) // 5 minutes in seconds
                .build();
    }
    
    @Transactional
    public MissionResponse validateOtp(UUID missionId, String requesterId, String otpCode) {
        log.info("Requester {} validating OTP for mission: {}", requesterId, missionId);
        
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new MissionNotFoundException("Mission not found with ID: " + missionId));
        
        // Verify user is requester
        if (!mission.getRequesterId().equals(requesterId)) {
            throw new UnauthorizedMissionAccessException("Only the requester can validate OTP");
        }
        
        // Verify mission status
        if (mission.getStatus() != MissionStatus.IN_PROGRESS) {
            throw new InvalidMissionStatusException("Mission must be IN_PROGRESS to validate OTP");
        }
        
        // Validate OTP
        if (!otpService.validateOtp(missionId, otpCode)) {
            throw new InvalidOtpException("Invalid or expired OTP code");
        }
        
        // Credit provider
        try {
            userClient.creditCredits(mission.getProviderId(), mission.getCreditCost());
        } catch (Exception e) {
            log.error("Failed to credit provider: {}", mission.getProviderId(), e);
            throw new RuntimeException("Failed to process credit transaction");
        }
        
        // Update mission
        mission.setStatus(MissionStatus.COMPLETED);
        mission.setCompletedAt(new Date());
        
        Mission updated = missionRepository.save(mission);
        log.info("Mission completed successfully");
        
        // Publish event
        eventPublisher.publishMissionCompleted(updated);
        
        SkillDto skill = null;
        try {
            skill = skillClient.getSkillById(mission.getSkillId());
        } catch (Exception e) {
            log.warn("Failed to fetch skill");
        }
        
        return mapToResponse(updated, skill, enrichWithUserData);
    }
    
    private MissionResponse mapToResponse(Mission mission, SkillDto skill, boolean enrichWithUser) {
        MissionResponse.MissionResponseBuilder builder = MissionResponse.builder()
                .missionId(mission.getMissionId())
                .skillId(mission.getSkillId())
                .requesterId(mission.getRequesterId())
                .providerId(mission.getProviderId())
                .title(mission.getTitle())
                .description(mission.getDescription())
                .status(mission.getStatus())
                .scheduledDate(mission.getScheduledDate())
                .duration(mission.getDuration())
                .creditCost(mission.getCreditCost())
                .createdAt(mission.getCreatedAt())
                .updatedAt(mission.getUpdatedAt())
                .acceptedAt(mission.getAcceptedAt())
                .startedAt(mission.getStartedAt())
                .completedAt(mission.getCompletedAt())
                .cancelledAt(mission.getCancelledAt())
                .cancellationReason(mission.getCancellationReason())
                .rejectionReason(mission.getRejectionReason());
        
        // Add skill info
        if (skill != null) {
            builder.skillTitle(skill.getTitle())
                   .skillCategory(skill.getCategory())
                   .latitude(skill.getLatitude())
                   .longitude(skill.getLongitude());
        }
        
        // Enrich with user data
        if (enrichWithUser) {
            try {
                UserDto requester = userClient.getUserById(mission.getRequesterId());
                builder.requesterName(requester.getFullName())
                       .requesterAvatar(requester.getAvatar());
                
                if (mission.getProviderId() != null) {
                    UserDto provider = userClient.getUserById(mission.getProviderId());
                    builder.providerName(provider.getFullName())
                           .providerAvatar(provider.getAvatar())
                           .providerScore((int) provider.getHelperScore());
                }
            } catch (Exception e) {
                log.warn("Failed to enrich mission with user data: {}", mission.getMissionId());
            }
        }
        
        return builder.build();
    }
}
