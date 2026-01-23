package com.skillswap.mission.repositories;

import com.skillswap.mission.enums.MissionStatus;
import com.skillswap.mission.model.Mission;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MissionRepository extends MongoRepository<Mission, UUID> {
    
    List<Mission> findByRequesterId(UUID requesterId);
    
    List<Mission> findByHelperId(UUID helperId);
    
    List<Mission> findByRequesterIdAndStatus(UUID requesterId, MissionStatus status);
    
    List<Mission> findByHelperIdAndStatus(UUID helperId, MissionStatus status);
    
    List<Mission> findBySkillId(UUID skillId);
    
    List<Mission> findByStatus(MissionStatus status);
}
