# Kafka Integration Guide

## Overview
This guide explains how to integrate Apache Kafka for event-driven communication between microservices in SkillSwap.

## Why Kafka?

### Benefits
- **Asynchronous Communication**: Services don't wait for responses
- **Decoupling**: Services don't need to know about each other
- **Scalability**: Handle high message throughput
- **Reliability**: Messages are persisted and can be replayed
- **Event Sourcing**: Track all state changes

### Use Cases in SkillSwap
- Mission created → Notify potential helpers
- Mission accepted → Notify requester
- Mission completed → Update user scores, send notifications
- Skill created → Notify nearby users
- Credit transaction → Audit logging

## Architecture

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Mission   │         │    Kafka    │         │Notification │
│   Service   │────────>│   Broker    │────────>│   Service   │
│   (8083)    │ Publish │             │ Consume │   (8084)    │
└─────────────┘         └─────────────┘         └─────────────┘
                              │
                              │ Subscribe
                              ▼
                        ┌─────────────┐
                        │   Analytics │
                        │   Service   │
                        └─────────────┘
```

## Setup

### 1. Add Dependencies (pom.xml)

```xml
<dependencies>
    <!-- Spring Kafka -->
    <dependency>
        <groupId>org.springframework.kafka</groupId>
        <artifactId>spring-kafka</artifactId>
    </dependency>
    
    <!-- For testing -->
    <dependency>
        <groupId>org.springframework.kafka</groupId>
        <artifactId>spring-kafka-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### 2. Docker Compose Configuration

```yaml
version: '3.8'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"
    networks:
      - skillswap-network

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    networks:
      - skillswap-network

networks:
  skillswap-network:
    driver: bridge
```

### 3. Start Kafka

```bash
docker-compose up -d zookeeper kafka
```

## Configuration

### application.yml (Producer - Mission Service)

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
      properties:
        spring.json.type.mapping: missionEvent:com.skillswap.common.events.MissionEvent
    admin:
      auto-create: true

# Topic configuration
kafka:
  topics:
    mission-events: mission-events
    skill-events: skill-events
    user-events: user-events
```

### application.yml (Consumer - Notification Service)

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: notification-service
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.type.mapping: missionEvent:com.skillswap.common.events.MissionEvent
        spring.json.trusted.packages: com.skillswap.common.events
      auto-offset-reset: earliest
```

## Event Models (skillswap-common)

### MissionEvent.java

```java
package com.skillswap.common.events;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MissionEvent {
    private UUID missionId;
    private UUID skillId;
    private UUID requesterId;
    private UUID helperId;
    private MissionEventType eventType;
    private String missionTitle;
    private Integer creditAmount;
    private Date timestamp;
    private Map<String, Object> metadata;
}
```

### MissionEventType.java

```java
package com.skillswap.common.events;

public enum MissionEventType {
    MISSION_CREATED,
    MISSION_ACCEPTED,
    MISSION_REJECTED,
    MISSION_STARTED,
    MISSION_COMPLETED,
    MISSION_CANCELLED
}
```

### SkillEvent.java

```java
package com.skillswap.common.events;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkillEvent {
    private UUID skillId;
    private UUID ownerId;
    private String title;
    private String category;
    private Double latitude;
    private Double longitude;
    private SkillEventType eventType;
    private Date timestamp;
}
```

## Producer Implementation (Mission Service)

### 1. Kafka Configuration

```java
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
```

### 2. Event Publisher Service

```java
package com.skillswap.mission.service;

import com.skillswap.common.events.MissionEvent;
import com.skillswap.common.events.MissionEventType;
import com.skillswap.mission.model.Mission;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
@RequiredArgsConstructor
@Slf4j
public class MissionEventPublisher {
    
    private final KafkaTemplate<String, MissionEvent> kafkaTemplate;
    
    @Value("${kafka.topics.mission-events}")
    private String missionEventsTopic;
    
    public void publishMissionCreated(Mission mission) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_CREATED);
        publishEvent(event);
    }
    
    public void publishMissionAccepted(Mission mission) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_ACCEPTED);
        publishEvent(event);
    }
    
    public void publishMissionCompleted(Mission mission) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_COMPLETED);
        publishEvent(event);
    }
    
    public void publishMissionCancelled(Mission mission, String reason) {
        MissionEvent event = buildEvent(mission, MissionEventType.MISSION_CANCELLED);
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("reason", reason);
        event.setMetadata(metadata);
        publishEvent(event);
    }
    
    private MissionEvent buildEvent(Mission mission, MissionEventType eventType) {
        return MissionEvent.builder()
                .missionId(mission.getMissionId())
                .skillId(mission.getSkillId())
                .requesterId(mission.getRequesterId())
                .helperId(mission.getHelperId())
                .eventType(eventType)
                .missionTitle(mission.getTitle())
                .creditAmount(mission.getCreditCost())
                .timestamp(new Date())
                .build();
    }
    
    private void publishEvent(MissionEvent event) {
        log.info("Publishing event: {} for mission: {}", 
                event.getEventType(), event.getMissionId());
        
        CompletableFuture<SendResult<String, MissionEvent>> future = 
                kafkaTemplate.send(missionEventsTopic, event.getMissionId().toString(), event);
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                log.info("Event published successfully: {} to partition: {}", 
                        event.getEventType(), result.getRecordMetadata().partition());
            } else {
                log.error("Failed to publish event: {}", event.getEventType(), ex);
            }
        });
    }
}
```

### 3. Use in Service Layer

```java
@Service
@RequiredArgsConstructor
public class MissionService {
    
    private final MissionRepository missionRepository;
    private final MissionEventPublisher eventPublisher;
    
    public MissionResponse createMission(CreateMissionRequest request, UUID requesterId) {
        // Create mission
        Mission mission = new Mission();
        mission.setMissionId(UUID.randomUUID());
        mission.setRequesterId(requesterId);
        mission.setStatus(MissionStatus.PENDING);
        // ... set other fields
        
        Mission saved = missionRepository.save(mission);
        
        // Publish event
        eventPublisher.publishMissionCreated(saved);
        
        return mapToResponse(saved);
    }
}
```

## Consumer Implementation (Notification Service)

### 1. Kafka Consumer Configuration

```java
package com.skillswap.notification.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;

@Configuration
@EnableKafka
public class KafkaConsumerConfig {
    // Configuration is in application.yml
}
```

### 2. Event Listener

```java
package com.skillswap.notification.listener;

import com.skillswap.common.events.MissionEvent;
import com.skillswap.common.events.MissionEventType;
import com.skillswap.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class MissionEventListener {
    
    private final NotificationService notificationService;
    
    @KafkaListener(
        topics = "${kafka.topics.mission-events}",
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleMissionEvent(
            @Payload MissionEvent event,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset) {
        
        log.info("Received event: {} for mission: {} from partition: {} offset: {}", 
                event.getEventType(), event.getMissionId(), partition, offset);
        
        try {
            switch (event.getEventType()) {
                case MISSION_CREATED:
                    handleMissionCreated(event);
                    break;
                case MISSION_ACCEPTED:
                    handleMissionAccepted(event);
                    break;
                case MISSION_COMPLETED:
                    handleMissionCompleted(event);
                    break;
                case MISSION_CANCELLED:
                    handleMissionCancelled(event);
                    break;
                default:
                    log.warn("Unknown event type: {}", event.getEventType());
            }
        } catch (Exception e) {
            log.error("Error processing event: {}", event.getEventType(), e);
            // Implement retry logic or dead letter queue
        }
    }
    
    private void handleMissionCreated(MissionEvent event) {
        // Notify skill owner about new mission request
        notificationService.sendMissionCreatedNotification(
                event.getHelperId(), 
                event.getMissionTitle()
        );
    }
    
    private void handleMissionAccepted(MissionEvent event) {
        // Notify requester that mission was accepted
        notificationService.sendMissionAcceptedNotification(
                event.getRequesterId(), 
                event.getMissionTitle()
        );
    }
    
    private void handleMissionCompleted(MissionEvent event) {
        // Notify both parties
        notificationService.sendMissionCompletedNotification(
                event.getRequesterId(), 
                event.getHelperId(),
                event.getMissionTitle(),
                event.getCreditAmount()
        );
    }
    
    private void handleMissionCancelled(MissionEvent event) {
        // Notify relevant party
        String reason = (String) event.getMetadata().get("reason");
        notificationService.sendMissionCancelledNotification(
                event.getRequesterId(),
                event.getHelperId(),
                event.getMissionTitle(),
                reason
        );
    }
}
```

## Error Handling

### 1. Retry Configuration

```yaml
spring:
  kafka:
    consumer:
      properties:
        spring.kafka.retry.topic.enabled: true
        spring.kafka.retry.topic.attempts: 3
        spring.kafka.retry.topic.delay: 1000
```

### 2. Dead Letter Queue

```java
@Bean
public ConcurrentKafkaListenerContainerFactory<String, MissionEvent> kafkaListenerContainerFactory(
        ConsumerFactory<String, MissionEvent> consumerFactory) {
    
    ConcurrentKafkaListenerContainerFactory<String, MissionEvent> factory = 
            new ConcurrentKafkaListenerContainerFactory<>();
    factory.setConsumerFactory(consumerFactory);
    
    // Configure error handler with DLT
    DefaultErrorHandler errorHandler = new DefaultErrorHandler(
            new DeadLetterPublishingRecoverer(kafkaTemplate),
            new FixedBackOff(1000L, 3L)
    );
    
    factory.setCommonErrorHandler(errorHandler);
    return factory;
}
```

## Testing

### 1. Embedded Kafka Test

```java
@SpringBootTest
@EmbeddedKafka(partitions = 1, topics = {"mission-events"})
class MissionEventPublisherTest {
    
    @Autowired
    private MissionEventPublisher eventPublisher;
    
    @Autowired
    private KafkaTemplate<String, MissionEvent> kafkaTemplate;
    
    @Test
    void shouldPublishMissionCreatedEvent() {
        // Given
        Mission mission = createTestMission();
        
        // When
        eventPublisher.publishMissionCreated(mission);
        
        // Then
        // Verify event was published
    }
}
```

### 2. Consumer Test

```java
@SpringBootTest
@EmbeddedKafka
class MissionEventListenerTest {
    
    @Autowired
    private KafkaTemplate<String, MissionEvent> kafkaTemplate;
    
    @MockBean
    private NotificationService notificationService;
    
    @Test
    void shouldHandleMissionCreatedEvent() throws Exception {
        // Given
        MissionEvent event = createTestEvent();
        
        // When
        kafkaTemplate.send("mission-events", event);
        
        // Then
        Thread.sleep(1000); // Wait for async processing
        verify(notificationService).sendMissionCreatedNotification(any(), any());
    }
}
```

## Monitoring

### 1. Kafka Metrics

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

### 2. Key Metrics to Monitor
- Message production rate
- Message consumption rate
- Consumer lag
- Failed messages
- Partition distribution

### 3. Kafka UI (Optional)

```yaml
# docker-compose.yml
kafka-ui:
  image: provectuslabs/kafka-ui:latest
  ports:
    - "8090:8080"
  environment:
    KAFKA_CLUSTERS_0_NAME: skillswap
    KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
```

Access at: http://localhost:8090

## Best Practices

1. **Event Versioning**: Include version field in events
2. **Idempotency**: Consumers should handle duplicate messages
3. **Schema Registry**: Use Confluent Schema Registry for production
4. **Partitioning**: Use meaningful partition keys (e.g., userId)
5. **Monitoring**: Track consumer lag and throughput
6. **Error Handling**: Implement DLQ for failed messages
7. **Testing**: Use embedded Kafka for integration tests
8. **Documentation**: Document all event types and schemas

## Troubleshooting

### Consumer Not Receiving Messages
- Check consumer group ID
- Verify topic name
- Check Kafka broker connectivity
- Review consumer offset (earliest vs latest)

### Messages Not Being Produced
- Check Kafka broker status
- Verify serialization configuration
- Review producer logs
- Check topic auto-creation settings

### High Consumer Lag
- Increase consumer instances
- Optimize message processing
- Check for blocking operations
- Review partition count

## Next Steps

1. Add Kafka to docker-compose.yml
2. Create event models in skillswap-common
3. Implement producer in Mission Service
4. Implement consumer in Notification Service
5. Add monitoring and alerting
6. Write integration tests
7. Document event schemas
