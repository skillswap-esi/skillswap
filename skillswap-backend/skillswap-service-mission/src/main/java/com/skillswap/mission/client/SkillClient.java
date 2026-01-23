package com.skillswap.mission.client;

import com.skillswap.mission.dto.SkillDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.UUID;

@FeignClient(name = "service-skill", url = "${skill.service.url}")
public interface SkillClient {
    
    @GetMapping("/api/skills/{skillId}")
    SkillDto getSkillById(@PathVariable("skillId") UUID skillId);
}
