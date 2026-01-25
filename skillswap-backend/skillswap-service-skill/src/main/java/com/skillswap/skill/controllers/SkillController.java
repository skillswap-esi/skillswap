package com.skillswap.skill.controllers;

import com.skillswap.skill.dto.CreateSkillRequest;
import com.skillswap.skill.dto.SkillResponse;
import com.skillswap.skill.dto.UpdateSkillRequest;
import com.skillswap.skill.services.SkillService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/skills")
@RequiredArgsConstructor
@Slf4j
public class SkillController {
    
    private final SkillService skillService;
    
    @PostMapping
    public ResponseEntity<SkillResponse> createSkill(
            @Valid @RequestBody CreateSkillRequest request,
            @RequestHeader("X-User-Id") String userId) {
        log.info("POST /skills - Creating skill for user: {}", userId);
        SkillResponse response = skillService.createSkill(request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @GetMapping("/near")
    public ResponseEntity<List<SkillResponse>> searchSkillsNear(
            @RequestParam Double lat,
            @RequestParam Double lng,
            @RequestParam(defaultValue = "10.0") Double radius,
            @RequestParam(required = false) String category) {
        log.info("GET /skills/near - lat: {}, lng: {}, radius: {}, category: {}", 
                lat, lng, radius, category);
        List<SkillResponse> skills = skillService.searchSkillsNear(lat, lng, radius, category);
        return ResponseEntity.ok(skills);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<SkillResponse>> getSkillsByUser(@PathVariable String userId) {
        log.info("GET /skills/user/{} - Getting skills for user", userId);
        List<SkillResponse> skills = skillService.getSkillsByUser(userId);
        return ResponseEntity.ok(skills);
    }
    
    @GetMapping("/{skillId}")
    public ResponseEntity<SkillResponse> getSkillById(@PathVariable UUID skillId) {
        log.info("GET /skills/{} - Getting skill by ID", skillId);
        try {
            SkillResponse skill = skillService.getSkillById(skillId);
            log.info("Found skill: {}", skill.getTitle());
            return ResponseEntity.ok(skill);
        } catch (Exception e) {
            log.error("Error getting skill {}: {}", skillId, e.getMessage());
            throw e;
        }
    }
    
    @PutMapping("/{skillId}")
    public ResponseEntity<SkillResponse> updateSkill(
            @PathVariable UUID skillId,
            @Valid @RequestBody UpdateSkillRequest request,
            @RequestHeader("X-User-Id") String userId) {
        log.info("PUT /skills/{} - Updating skill by user: {}", skillId, userId);
        SkillResponse response = skillService.updateSkill(skillId, request, userId);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{skillId}")
    public ResponseEntity<Void> deleteSkill(
            @PathVariable UUID skillId,
            @RequestHeader("X-User-Id") String userId) {
        log.info("DELETE /skills/{} - Deleting skill by user: {}", skillId, userId);
        skillService.deleteSkill(skillId, userId);
        return ResponseEntity.noContent().build();
    }
}
