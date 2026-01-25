package com.skillswap.mission.services;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {
    
    private final RedisTemplate<String, String> redisTemplate;
    
    @Value("${otp.expiration-minutes}")
    private Integer expirationMinutes;
    
    @Value("${otp.length}")
    private Integer otpLength;
    
    private static final String OTP_KEY_PREFIX = "mission:otp:";
    
    public String generateOtp(UUID missionId) {
        String otp = generateRandomOtp();
        String key = OTP_KEY_PREFIX + missionId;
        
        redisTemplate.opsForValue().set(key, otp, expirationMinutes, TimeUnit.MINUTES);
        log.info("OTP generated for mission: {}", missionId);
        
        return otp;
    }
    
    public boolean validateOtp(UUID missionId, String otp) {
        String key = OTP_KEY_PREFIX + missionId;
        String storedOtp = redisTemplate.opsForValue().get(key);
        
        if (storedOtp != null && storedOtp.equals(otp)) {
            redisTemplate.delete(key);
            log.info("OTP validated successfully for mission: {}", missionId);
            return true;
        }
        
        log.warn("Invalid OTP attempt for mission: {}", missionId);
        return false;
    }
    
    public void deleteOtp(UUID missionId) {
        String key = OTP_KEY_PREFIX + missionId;
        redisTemplate.delete(key);
        log.info("OTP deleted for mission: {}", missionId);
    }
    
    private String generateRandomOtp() {
        Random random = new Random();
        int max = (int) Math.pow(10, otpLength) - 1;
        int otp = random.nextInt(max);
        return String.format("%0" + otpLength + "d", otp);
    }
}
