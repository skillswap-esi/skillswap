package com.skillswap.skill.repositories;

import com.skillswap.skill.model.Skill;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SkillRepository extends MongoRepository<Skill, UUID> {
    
    List<Skill> findByOwnerId(UUID ownerId);
    
    List<Skill> findByCategory(String category);
    
    List<Skill> findByOwnerIdAndActive(UUID ownerId, boolean active);
    
    List<Skill> findByActiveTrue();
}
