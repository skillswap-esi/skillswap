package com.skillswap.mission.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaTopicConfig {
    
    @Value("${kafka.topics.mission-events}")
    private String missionEventsTopic;
    
    @Bean
    public NewTopic missionEventsTopic() {
        return TopicBuilder.name(missionEventsTopic)
                .partitions(3)
                .replicas(1)
                .build();
    }
}
