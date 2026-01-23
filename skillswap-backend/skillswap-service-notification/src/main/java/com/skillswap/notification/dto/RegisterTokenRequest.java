package com.skillswap.notification.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterTokenRequest {
    
    @NotBlank(message = "FCM token is required")
    private String token;
    
    @NotBlank(message = "Device type is required")
    private String deviceType;  // android, ios, web
}
