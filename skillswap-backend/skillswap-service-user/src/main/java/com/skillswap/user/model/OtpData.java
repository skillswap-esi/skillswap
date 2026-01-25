package com.skillswap.user.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OtpData {
    private String otpHashed;
    private long expiresAt;
    private int attempts;
}
