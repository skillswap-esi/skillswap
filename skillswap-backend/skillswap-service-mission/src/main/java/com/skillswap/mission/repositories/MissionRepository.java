package com.skillswap.mission.repositories;

import com.skillswap.mission.enums.MissionStatus;
import com.skillswap.mission.model.Mission;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MissionRepository extends MongoRepository<Mission, UUID> {
    
    List<Mission> findByRequesterId(String requesterId);
    
    List<Mission> findByProviderId(String providerId);
    
    List<Mission> findByRequesterIdAndStatus(String requesterId, MissionStatus status);
    
    List<Mission> findByProviderIdAndStatus(String providerId, MissionStatus status);
    
    List<Mission> findBySkillId(UUID skillId);
    
    List<Mission> findBySkillIdAndStatus(UUID skillId, MissionStatus status);
    
    List<Mission> findByStatus(MissionStatus status);
}
