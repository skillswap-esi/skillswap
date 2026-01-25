package com.skillswap.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        return http
                // Disable CSRF for API
                .csrf(ServerHttpSecurity.CsrfSpec::disable)
                // Enable CORS - uses CorsWebFilter bean from CorsConfig
                .cors(cors -> {})
                // Disable HTTP Basic Auth (prevents browser login popup)
                .httpBasic(ServerHttpSecurity.HttpBasicSpec::disable)
                // Disable Form Login
                .formLogin(ServerHttpSecurity.FormLoginSpec::disable)
                // Allow all exchanges - JWT validation is done in JwtAuthenticationFilter
                .authorizeExchange(exchanges -> exchanges
                        .anyExchange().permitAll()
                )
                .build();
    }
}

