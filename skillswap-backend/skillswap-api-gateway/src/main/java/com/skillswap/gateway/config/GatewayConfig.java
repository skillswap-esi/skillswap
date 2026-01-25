package com.skillswap.gateway.config;

import com.skillswap.gateway.filter.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                // User Service - Auth (Public - NO JWT filter)
                // Remove Authorization header to avoid issues with cached Basic Auth credentials
                .route("user-service-auth", r -> r
                        .path("/api/auth/**")
                        .filters(f -> f
                                .stripPrefix(1)
                                .removeRequestHeader("Authorization")  // Remove cached Basic Auth
                                .removeRequestHeader("Cookie"))        // Remove session cookies
                        .uri("http://localhost:8081"))
                
                // User Service - Admin Login (Public - NO JWT filter)
                // Backoffice needs to login to GET a JWT token
                .route("user-service-admin-login", r -> r
                        .path("/api/admin/login")
                        .filters(f -> f
                                .stripPrefix(1)
                                .removeRequestHeader("Cookie"))
                        .uri("http://localhost:8081"))
                
                // User Service - Admin Routes (Backoffice - NO JWT for now)
                // These routes are for backoffice management
                .route("user-service-admin", r -> r
                        .path("/api/admin/**")
                        .filters(f -> f
                                .stripPrefix(1))
                        .uri("http://localhost:8081"))
                
                // User Service - Protected (requires JWT)
                .route("user-service", r -> r
                        .path("/api/users/**")
                        .filters(f -> f
                                .stripPrefix(1)
                                .filter(jwtAuthenticationFilter))
                        .uri("http://localhost:8081"))
                
                // Skill Service - Protected (requires JWT)
                .route("skill-service", r -> r
                        .path("/api/skills/**")
                        .filters(f -> f
                                .stripPrefix(1)
                                .filter(jwtAuthenticationFilter))
                        .uri("http://localhost:8082"))
                
                // Mission Service - Partner Places (Backoffice - NO JWT for management)
                // stripPrefix(1) removes /api → missions/partner-places/...
                .route("mission-service-partner-places", r -> r
                        .path("/api/missions/partner-places/**")
                        .filters(f -> f
                                .stripPrefix(1))
                        .uri("http://localhost:8083"))
                
                // Mission Service - Protected (requires JWT)
                // stripPrefix(1) removes /api → missions/...
                .route("mission-service", r -> r
                        .path("/api/missions/**")
                        .filters(f -> f
                                .stripPrefix(1)
                                .filter(jwtAuthenticationFilter))
                        .uri("http://localhost:8083"))
                
                // Notification Service - Protected (requires JWT)
                .route("notification-service", r -> r
                        .path("/api/notifications/**")
                        .filters(f -> f
                                .stripPrefix(1)
                                .filter(jwtAuthenticationFilter))
                        .uri("http://localhost:8084"))
                
                .build();
    }
}

