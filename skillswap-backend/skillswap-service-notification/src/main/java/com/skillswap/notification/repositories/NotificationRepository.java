package com.skillswap.notification.repositories;

import com.skillswap.notification.model.Notification;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends MongoRepository<Notification, UUID> {
    
    List<Notification> findByUserIdOrderBySentAtDesc(UUID userId);
    
    List<Notification> findByUserIdAndReadOrderBySentAtDesc(UUID userId, boolean read);
    
    long countByUserIdAndRead(UUID userId, boolean read);
}
