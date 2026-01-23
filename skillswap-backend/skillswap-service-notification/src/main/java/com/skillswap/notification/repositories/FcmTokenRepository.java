package com.skillswap.notification.repositories;

import com.skillswap.notification.model.FcmToken;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface FcmTokenRepository extends MongoRepository<FcmToken, UUID> {
    
    Optional<FcmToken> findByUserId(UUID userId);
    
    Optional<FcmToken> findByToken(String token);
}
