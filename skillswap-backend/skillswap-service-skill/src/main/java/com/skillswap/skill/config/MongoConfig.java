package com.skillswap.skill.config;

import com.skillswap.skill.model.Skill;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.GeospatialIndex;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class MongoConfig {
    
    private final MongoTemplate mongoTemplate;
    
    @PostConstruct
    public void initIndexes() {
        log.info("Ensuring geospatial index for skills collection");
        
        try {
            // Drop old 2d index if exists
            try {
                mongoTemplate.indexOps(Skill.class).dropIndex("geoPoint");
                log.info("Dropped old geoPoint index");
            } catch (Exception e) {
                log.debug("No old index to drop: {}", e.getMessage());
            }
            
            // Create 2dsphere index on geoPoint field
            GeospatialIndex index = new GeospatialIndex("geoPoint");
            index.typed(org.springframework.data.mongodb.core.index.GeoSpatialIndexType.GEO_2DSPHERE);
            
            mongoTemplate.indexOps(Skill.class).ensureIndex(index);
            
            log.info("Geospatial 2dsphere index created successfully");
        } catch (Exception e) {
            log.error("Error creating geospatial index: {}", e.getMessage());
        }
    }
}
