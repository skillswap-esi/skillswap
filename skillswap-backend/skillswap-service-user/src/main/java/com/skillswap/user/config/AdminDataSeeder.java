package com.skillswap.user.config;

import com.skillswap.user.model.User;
import com.skillswap.user.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;
import java.util.UUID;

/**
 * Data Seeder for Admin User
 * 
 * Seeds the admin user for backoffice login.
 * Credentials (as documented):
 * - Email: admin@skillswap.com
 * - Password: Admin123!
 * 
 * This does NOT affect mobile users - it only creates one admin account.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class AdminDataSeeder implements CommandLineRunner {
    
    private final UserRepository userRepository;
    
    private static final String ADMIN_EMAIL = "admin@skillswap.com";
    private static final String ADMIN_PASSWORD = "Admin123!";
    
    @Override
    public void run(String... args) {
        seedAdminUser();
    }
    
    private void seedAdminUser() {
        // Check if admin user already exists
        if (userRepository.findByEmail(ADMIN_EMAIL).isPresent()) {
            log.info("Admin user already exists, skipping seed");
            return;
        }
        
        log.info("Seeding admin user: {}", ADMIN_EMAIL);
        
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String hashedPassword = encoder.encode(ADMIN_PASSWORD);
        
        User admin = new User();
        admin.setUserId(UUID.randomUUID());
        admin.setEmail(ADMIN_EMAIL);
        admin.setFullName("SkillSwap Admin");
        admin.setPhoneNumber(null);
        admin.setPhoneVerified(false);
        admin.setCreditsBalance(0);
        admin.setHelperScore(0.0f);
        admin.setRoles(List.of("ADMIN"));
        admin.setFcmTokens(List.of());
        admin.setPasswordHash(hashedPassword);
        admin.setCreatedAt(new Date());
        admin.setUpdatedAt(new Date());
        
        userRepository.save(admin);
        
        log.info("Admin user seeded successfully with email: {}", ADMIN_EMAIL);
        log.info("Admin credentials: email={}, password={}", ADMIN_EMAIL, ADMIN_PASSWORD);
    }
}
