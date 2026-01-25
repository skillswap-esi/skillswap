package com.skillswap.skill.repositories;

import com.skillswap.skill.model.Skill;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.Point;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SkillRepository extends MongoRepository<Skill, UUID> {
    
    List<Skill> findByOwnerId(String ownerId);
    
    List<Skill> findByGeoPointNear(Point point, Distance distance);
    
    List<Skill> findByActiveTrue();
    
    List<Skill> findByCategory(String category);
}
