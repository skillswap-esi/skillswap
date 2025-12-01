package com.skillswap.user.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document("users")
public class User {
    
    @Id
    private UUID userId;
    
    @Indexed(unique = true)
    private String email;
    
    @Indexed(unique = true)
    private String phoneNumber;
    
    private String fullName;
    private boolean phoneVerified;
    private int creditsBalance; // >= 0
    private float helperScore; // 0..5
    private String avatar; // URL ou key
    private List<String> roles; // ["USER"], ["ADMIN"]
    private Date createdAt;
    private Date updatedAt;
}
