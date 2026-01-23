package com.skillswap.gateway.filter;

import com.skillswap.gateway.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;

@Component
@Slf4j
public class JwtAuthenticationFilter implements GatewayFilter {

    @Autowired
    private JwtUtil jwtUtil;

    private static final List<String> PUBLIC_PATHS = List.of(
            "/auth/register",
            "/auth/login",
            "/auth/firebase-login",
            "/skills/near",           // Public: Browse nearby skills
            "/skills/user/",          // Public: View user's skills
            "/skills/"                // Public: View skill details (GET only)
    );

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getPath().toString();
        String method = request.getMethod().name();

        log.debug("Processing request: {} {}", method, path);

        // Skip authentication for public paths (GET only)
        if (isPublicPath(path) && "GET".equals(method)) {
            log.debug("Public GET path, skipping authentication: {}", path);
            
            // For public paths, try to extract user ID if token is present (optional auth)
            String authHeader = request.getHeaders().getFirst("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                try {
                    if (jwtUtil.validateToken(token)) {
                        String userId = jwtUtil.extractUserId(token);
                        log.debug("Optional authentication for public path - user: {}", userId);
                        
                        ServerHttpRequest modifiedRequest = request.mutate()
                                .header("X-User-Id", userId)
                                .build();
                        return chain.filter(exchange.mutate().request(modifiedRequest).build());
                    }
                } catch (Exception e) {
                    log.debug("Invalid token on public path, proceeding without auth: {}", e.getMessage());
                }
            }
            
            return chain.filter(exchange);
        }

        // Extract token from Authorization header (required for protected paths)
        String authHeader = request.getHeaders().getFirst("Authorization");
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.warn("Missing or invalid Authorization header for path: {} {}", method, path);
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String token = authHeader.substring(7);

        try {
            // Validate token
            if (!jwtUtil.validateToken(token)) {
                log.warn("Invalid or expired token for path: {}. Proceeding anyway (Dev Mode).", path);
                // exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                // return exchange.getResponse().setComplete();
            }

            // Extract user ID and add to header
            try {
                String userId = jwtUtil.extractUserId(token);
                log.debug("Authenticated user: {}", userId);

                // Add X-User-Id header for downstream services
                ServerHttpRequest modifiedRequest = request.mutate()
                        .header("X-User-Id", userId)
                        .build();

                return chain.filter(exchange.mutate().request(modifiedRequest).build());
            } catch (Exception e) {
                log.warn("Could not extract user ID from token: {}. Proceeding without X-User-Id.", e.getMessage());
                return chain.filter(exchange);
            }

        } catch (Exception e) {
            log.error("Error validating token: {}. Proceeding anyway (Dev Mode).", e.getMessage());
            // exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            // return exchange.getResponse().setComplete();
            return chain.filter(exchange);
        }
    }

    private boolean isPublicPath(String path) {
        return PUBLIC_PATHS.stream().anyMatch(path::contains);
    }
}
