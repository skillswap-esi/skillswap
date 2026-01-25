package com.skillswap.skill.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
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
    private Date createdAt;
}
