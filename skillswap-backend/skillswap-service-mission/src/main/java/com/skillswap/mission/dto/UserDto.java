package com.skillswap.mission.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private UUID userId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String avatar;
    private Integer helperScore;
    private Integer credits;
}
