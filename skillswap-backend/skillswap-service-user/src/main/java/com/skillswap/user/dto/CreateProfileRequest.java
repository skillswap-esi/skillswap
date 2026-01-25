package com.skillswap.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateProfileRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    private String phoneNumber;
    
    @NotBlank(message = "Full name is required")
    private String fullName;
    
    @NotBlank(message = "Firebase ID token is required")
    private String idToken;
}
