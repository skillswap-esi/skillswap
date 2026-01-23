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
            log.info("Initializing geospatial indexes for skills collection");
            
            // Get existing indexes
            List<IndexInfo> existingIndexes = mongoTemplate.indexOps(Skill.class).getIndexInfo();
            
            // Drop any existing geoPoint index (might be wrong type)
            for (IndexInfo indexInfo : existingIndexes) {
                String indexName = indexInfo.getName();
                if (indexName.contains("geoPoint") && !indexName.equals("_id_")) {
                    log.info("Dropping existing geoPoint index: {}", indexName);
                    try {
                        mongoTemplate.indexOps(Skill.class).dropIndex(indexName);
                        log.info("Successfully dropped index: {}", indexName);
                    } catch (Exception dropEx) {
                        log.warn("Could not drop index {}: {}", indexName, dropEx.getMessage());
                    }
                }
            }
            
            // Create 2dsphere index for GeoJsonPoint
            log.info("Creating 2dsphere geospatial index for geoPoint field");
            GeospatialIndex index = new GeospatialIndex("geoPoint")
                    .typed(GeoSpatialIndexType.GEO_2DSPHERE);
            
            mongoTemplate.indexOps(Skill.class).ensureIndex(index);
            
            log.info("Geospatial index created successfully");
        } catch (Exception e) {
            log.error("Error managing geospatial index: {}", e.getMessage());
            log.error("Please manually clean MongoDB Atlas:");
            log.error("1. Go to your cluster -> Browse Collections -> skills");
            log.error("2. Click on 'Indexes' tab");
            log.error("3. Drop all indexes except '_id_'");
            log.error("4. Restart this service");
        }
    }
}
