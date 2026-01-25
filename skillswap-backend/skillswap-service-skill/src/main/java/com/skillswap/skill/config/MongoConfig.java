package com.skillswap.skill.config;

import com.skillswap.skill.model.Skill;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.GeospatialIndex;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexType;
import org.springframework.data.mongodb.core.index.IndexInfo;

import java.util.List;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class MongoConfig {
    
    private final MongoTemplate mongoTemplate;
    
    @PostConstruct
    public void initIndexes() {
        try {
            log.info("Checking geospatial indexes for skills collection");

            // Get existing indexes
            List<IndexInfo> existingIndexes = mongoTemplate.indexOps(Skill.class).getIndexInfo();
            
            // Check if a valid 2dsphere index on geoPoint already exists
            boolean geoIndexExists = existingIndexes.stream()
                    .anyMatch(idx -> idx.getName().contains("geoPoint"));

            if (geoIndexExists) {
                log.info("Geospatial index on geoPoint already exists, skipping creation");
                return;
            }
            
            // Create 2dsphere index for GeoJsonPoint only if it doesn't exist
            log.info("Creating 2dsphere geospatial index for geoPoint field");
            GeospatialIndex index = new GeospatialIndex("geoPoint")
                    .typed(GeoSpatialIndexType.GEO_2DSPHERE);
            
            mongoTemplate.indexOps(Skill.class).ensureIndex(index);
            
            log.info("Geospatial index created successfully");
        } catch (Exception e) {
            log.warn("Could not manage geospatial index: {}. This is usually safe to ignore if the index already exists.", e.getMessage());
        }
    }
}
