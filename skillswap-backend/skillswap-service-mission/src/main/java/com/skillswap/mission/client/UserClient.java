package com.skillswap.mission.client;

import com.skillswap.mission.dto.UserDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@FeignClient(name = "service-user", url = "${user.service.url}")
public interface UserClient {
    
    @GetMapping("/api/users/{userId}")
    UserDto getUserById(@PathVariable("userId") UUID userId);
    
    @PostMapping("/api/users/{userId}/credits/debit")
    void debitCredits(@PathVariable("userId") UUID userId, @RequestParam("amount") Integer amount);
    
    @PostMapping("/api/users/{userId}/credits/credit")
    void creditCredits(@PathVariable("userId") UUID userId, @RequestParam("amount") Integer amount);
}
