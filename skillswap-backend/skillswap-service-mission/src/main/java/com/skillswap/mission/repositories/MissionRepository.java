package com.skillswap.mission.repositories;

import com.skillswap.mission.model.Mission;
import com.skillswap.mission.model.MissionStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MissionRepository extends MongoRepository<Mission, UUID> {
    
    List<Mission> findByRequesterId(UUID requesterId);
    
    List<Mission> findByProviderId(UUID providerId);
    
    List<Mission> findByStatus(MissionStatus status);
    
    List<Mission> findByRequesterIdOrProviderId(UUID requesterId, UUID providerId);
}
