package com.skillswap.user.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Security configuration for the User Service.
 * 
 * This service handles its own authentication via Firebase Admin SDK,
 * so we disable Spring Security's default authentication mechanisms.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                // Disable CSRF for REST API
                .csrf(csrf -> csrf.disable())
                // Disable HTTP Basic Auth (prevents browser login popup)
                .httpBasic(basic -> basic.disable())
                // Disable Form Login
                .formLogin(form -> form.disable())
                // Stateless session - no cookies
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // Allow all requests - we use Firebase Admin SDK for auth
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/**").permitAll()  // Auth endpoints are public
                        .requestMatchers("/actuator/**").permitAll()  // Health checks
                        .anyRequest().permitAll()  // All other requests handled by custom logic
                )
                .build();
    }
}
