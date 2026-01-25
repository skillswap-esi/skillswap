package com.skillswap.skill.services;

import com.skillswap.skill.client.UserClient;
import com.skillswap.skill.dto.CreateSkillRequest;
import com.skillswap.skill.dto.SkillResponse;
import com.skillswap.skill.dto.UpdateSkillRequest;
import com.skillswap.skill.dto.UserDto;
import com.skillswap.skill.exceptions.SkillNotFoundException;
import com.skillswap.skill.exceptions.UnauthorizedException;
import com.skillswap.skill.model.Skill;
import com.skillswap.skill.repositories.SkillRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.Metrics;
import org.springframework.data.geo.Point;
import org.springframework.data.mongodb.core.geo.GeoJsonPoint;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class SkillService {
    
    private final SkillRepository skillRepository;
    private final UserClient userClient;
    
    @Value("${skill.enrich-with-user-data:false}")
    private boolean enrichWithUserData;
    
    public SkillResponse createSkill(CreateSkillRequest request, String ownerId) {
        log.info("Creating skill for owner: {}", ownerId);
        
        Skill skill = new Skill();
        skill.setSkillId(UUID.randomUUID());
        skill.setOwnerId(ownerId);
        skill.setTitle(request.getTitle());
        skill.setDescription(request.getDescription());
        skill.setCategory(request.getCategory().toUpperCase());
        skill.setGeoPoint(new GeoJsonPoint(request.getLongitude(), request.getLatitude()));
        skill.setActive(true);
        skill.setCreatedAt(new Date());
        skill.setUpdatedAt(new Date());
        
        Skill savedSkill = skillRepository.save(skill);
        log.info("Skill created successfully with ID: {}", savedSkill.getSkillId());
        
        return mapToResponse(savedSkill, enrichWithUserData);
    }
    
    public List<SkillResponse> searchSkillsNear(Double latitude, Double longitude, Double radiusKm, String category) {
        log.info("Searching skills near lat: {}, lng: {}, radius: {} km, category: {}", 
                latitude, longitude, radiusKm, category);
        
        Point location = new Point(longitude, latitude);
        Distance distance = new Distance(radiusKm, Metrics.KILOMETERS);
        
        List<Skill> skills = skillRepository.findByGeoPointNear(location, distance);
        
        // Filter by category if provided
        if (category != null && !category.isEmpty()) {
            skills = skills.stream()
                    .filter(skill -> skill.getCategory().equalsIgnoreCase(category))
                    .collect(Collectors.toList());
        }
        
        // Filter only active skills
        skills = skills.stream()
                .filter(Skill::isActive)
                .collect(Collectors.toList());
        
        log.info("Found {} skills", skills.size());
        
        return skills.stream()
                .map(skill -> {
                    SkillResponse response = mapToResponse(skill, enrichWithUserData);
                    response.setDistance(calculateDistance(latitude, longitude, 
                            skill.getGeoPoint().getY(), skill.getGeoPoint().getX()));
                    return response;
                })
                .sorted((s1, s2) -> Double.compare(s1.getDistance(), s2.getDistance()))
                .collect(Collectors.toList());
    }
    
    public List<SkillResponse> getSkillsByUser(String userId) {
        log.info("Getting skills for user: {}", userId);
        List<Skill> skills = skillRepository.findByOwnerId(userId);
        return skills.stream()
                .map(skill -> mapToResponse(skill, false))
                .collect(Collectors.toList());
    }
    
    public SkillResponse getSkillById(UUID skillId) {
        log.info("Getting skill by ID: {}", skillId);
        Skill skill = skillRepository.findById(skillId)
                .orElseThrow(() -> new SkillNotFoundException("Skill not found with ID: " + skillId));
        return mapToResponse(skill, enrichWithUserData);
    }
    
    public SkillResponse updateSkill(UUID skillId, UpdateSkillRequest request, String ownerId) {
        log.info("Updating skill: {} by owner: {}", skillId, ownerId);
        
        Skill skill = skillRepository.findById(skillId)
                .orElseThrow(() -> new SkillNotFoundException("Skill not found with ID: " + skillId));
        
        if (!skill.getOwnerId().equals(ownerId)) {
            throw new UnauthorizedException("You can only update your own skills");
        }
        
        if (request.getTitle() != null) {
            skill.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            skill.setDescription(request.getDescription());
        }
        if (request.getCategory() != null) {
            skill.setCategory(request.getCategory().toUpperCase());
        }
        if (request.getLatitude() != null && request.getLongitude() != null) {
            skill.setGeoPoint(new GeoJsonPoint(request.getLongitude(), request.getLatitude()));
        }
        if (request.getActive() != null) {
            skill.setActive(request.getActive());
        }
        
        skill.setUpdatedAt(new Date());
        
        Skill updatedSkill = skillRepository.save(skill);
        log.info("Skill updated successfully");
        
        return mapToResponse(updatedSkill, false);
    }
    
    public void deleteSkill(UUID skillId, String ownerId) {
        log.info("Deleting skill: {} by owner: {}", skillId, ownerId);
        
        Skill skill = skillRepository.findById(skillId)
                .orElseThrow(() -> new SkillNotFoundException("Skill not found with ID: " + skillId));
        
        if (!skill.getOwnerId().equals(ownerId)) {
            throw new UnauthorizedException("You can only delete your own skills");
        }
        
        skillRepository.delete(skill);
        log.info("Skill deleted successfully");
    }
    
    private SkillResponse mapToResponse(Skill skill, boolean enrichWithUser) {
        SkillResponse response = SkillResponse.builder()
                .skillId(skill.getSkillId())
                .ownerId(skill.getOwnerId())
                .title(skill.getTitle())
                .description(skill.getDescription())
                .category(skill.getCategory())
                .latitude(skill.getGeoPoint().getY())
                .longitude(skill.getGeoPoint().getX())
                .active(skill.isActive())
                .createdAt(skill.getCreatedAt())
                .updatedAt(skill.getUpdatedAt())
                .build();
        
        // Optionally enrich with user data
        if (enrichWithUser) {
            try {
                UserDto owner = userClient.getUserById(skill.getOwnerId());
                response.setOwnerName(owner.getFullName());
                response.setOwnerScore(owner.getHelperScore());
                response.setOwnerAvatar(owner.getAvatar());
            } catch (Exception e) {
                log.warn("Failed to fetch user data for ownerId: {}", skill.getOwnerId());
            }
        }
        
        return response;
    }
    
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c;
    }
}
