package com.skillswap.mission.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private UUID userId;
    private String email;
    private String phoneNumber;
    private String fullName;
    private boolean phoneVerified;
    private int creditsBalance;
    private float helperScore;
    private String avatar;
    private List<String> roles;
    private List<String> fcmTokens;
    private Date createdAt;
    private Date updatedAt;
}
