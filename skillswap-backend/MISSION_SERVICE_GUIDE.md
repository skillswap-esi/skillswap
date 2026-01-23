# Mission Service - Implementation Guide

## Overview
The Mission Service manages the complete lifecycle of skill exchange missions, including OTP validation, credit management, and event publishing.

## Architecture

### Port: 8083

### Dependencies
- **MongoDB**: Mission storage
- **Redis**: Temporary OTP storage (5 min expiration)
- **Kafka**: Event publishing
- **User Service** (8081): Credit verification
- **Skill Service** (8082): Skill retrieval

## Data Model

### Mission Entity
```java
@Document("missions")
public class Mission {
    @Id
    private UUID missionId;
    
    @Indexed
    private UUID skillId;           // Related skill
    
    @Indexed
    private UUID requesterId;       // Person requesting help
    
    @Indexed
    private UUID helperId;          // Person providing help (null until accepted)
    
    private String title;
    private String description;
    
    @Indexed
    private MissionStatus status;   // PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED, REJECTED
    
    private Date scheduledDate;     // Scheduled date/time
    private Integer duration;       // Duration in minutes
    private Integer creditCost;     // Cost in credits
    
    private Date createdAt;
    private Date acceptedAt;
    private Date completedAt;
    private Date cancelledAt;
    
    // Location (copied from skill for convenience)
    private GeoJsonPoint geoPoint;
    private String location;
}
```

### Mission Status Flow
```
PENDING → ACCEPTED → IN_PROGRESS → COMPLETED
   ↓          ↓            ↓
REJECTED  CANCELLED    CANCELLED
```

## API Endpoints

### Create Mission
```
POST /api/missions
Headers: Authorization: Bearer {jwt}, X-User-Id: {uuid}
Body: {
  "skillId": "uuid",
  "title": "Need help with guitar",
  "description": "Learn basic chords",
  "scheduledDate": "2026-01-25T14:00:00Z",
  "duration": 60,
  "creditCost": 10
}
Response: MissionResponse
```

### Get Mission by ID
```
GET /api/missions/{missionId}
Response: MissionResponse with enriched user data
```

### List User Missions
```
GET /api/missions/user/{userId}?status=PENDING&role=REQUESTER
Query params:
  - status: Filter by status (optional)
  - role: REQUESTER or HELPER (optional)
Response: List<MissionResponse>
```

### Accept Mission
```
POST /api/missions/{missionId}/accept
Headers: X-User-Id: {helperId}
Response: MissionResponse
```

### Reject Mission
```
POST /api/missions/{missionId}/reject
Headers: X-User-Id: {helperId}
Body: { "reason": "Not available" }
Response: 200 OK
```

### Cancel Mission
```
POST /api/missions/{missionId}/cancel
Headers: X-User-Id: {requesterId or helperId}
Body: { "reason": "Schedule conflict" }
Response: 200 OK
```

### Generate OTP
```
POST /api/missions/{missionId}/generate-otp
Headers: X-User-Id: {helperId}
Response: { "otpCode": "123456", "expiresIn": 300 }
```

### Validate OTP
```
POST /api/missions/{missionId}/validate-otp
Headers: X-User-Id: {requesterId}
Body: { "otpCode": "123456" }
Response: MissionResponse (status: COMPLETED)
```

## Business Logic

### 1. Create Mission
- Verify requester has sufficient credits
- Verify skill exists and is active
- Debit credits from requester immediately
- Set status to PENDING
- Publish `MissionCreatedEvent` to Kafka

### 2. Accept Mission
- Only skill owner can accept
- Mission must be in PENDING status
- Set helperId and status to ACCEPTED
- Publish `MissionAcceptedEvent` to Kafka

### 3. Start Mission
- Either requester or helper can start
- Mission must be ACCEPTED
- Set status to IN_PROGRESS

### 4. Generate OTP
- Only helper can generate
- Mission must be IN_PROGRESS
- Generate 6-digit code
- Store in Redis with 5-minute expiration
- Key format: `mission:otp:{missionId}`

### 5. Validate OTP
- Only requester can validate
- Mission must be IN_PROGRESS
- Verify OTP from Redis
- Credit helper with mission cost
- Set status to COMPLETED
- Delete OTP from Redis
- Publish `MissionCompletedEvent` to Kafka

### 6. Cancel Mission
- Requester or helper can cancel
- Cannot cancel if COMPLETED
- Refund credits to requester if not yet started
- Publish `MissionCancelledEvent` to Kafka

## Credit Management

### Debit Flow (Create Mission)
```java
@FeignClient(name = "service-user", url = "${user.service.url}")
public interface UserClient {
    @PostMapping("/api/users/{userId}/credits/debit")
    void debitCredits(@PathVariable UUID userId, @RequestParam Integer amount);
}
```

### Credit Flow (Complete Mission)
```java
@PostMapping("/api/users/{userId}/credits/credit")
void creditCredits(@PathVariable UUID userId, @RequestParam Integer amount);
```

### Refund Flow (Cancel Mission)
- If status is PENDING or ACCEPTED: Full refund
- If status is IN_PROGRESS: No refund (negotiation required)

## Redis OTP Storage

### Configuration
```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      timeout: 2000ms
```

### OTP Operations
```java
@Service
public class OtpService {
    private final RedisTemplate<String, String> redisTemplate;
    
    public String generateOtp(UUID missionId) {
        String otp = String.format("%06d", new Random().nextInt(999999));
        String key = "mission:otp:" + missionId;
        redisTemplate.opsForValue().set(key, otp, 5, TimeUnit.MINUTES);
        return otp;
    }
    
    public boolean validateOtp(UUID missionId, String otp) {
        String key = "mission:otp:" + missionId;
        String stored = redisTemplate.opsForValue().get(key);
        if (stored != null && stored.equals(otp)) {
            redisTemplate.delete(key);
            return true;
        }
        return false;
    }
}
```

## Kafka Events

### Event Types
```java
public enum MissionEventType {
    MISSION_CREATED,
    MISSION_ACCEPTED,
    MISSION_REJECTED,
    MISSION_STARTED,
    MISSION_COMPLETED,
    MISSION_CANCELLED
}
```

### Event Structure
```java
@Data
public class MissionEvent {
    private UUID missionId;
    private UUID skillId;
    private UUID requesterId;
    private UUID helperId;
    private MissionEventType eventType;
    private MissionStatus status;
    private Integer creditAmount;
    private Date timestamp;
    private Map<String, Object> metadata;
}
```

### Publishing Events
```java
@Service
public class MissionEventPublisher {
    private final KafkaTemplate<String, MissionEvent> kafkaTemplate;
    
    public void publishMissionCreated(Mission mission) {
        MissionEvent event = MissionEvent.builder()
            .missionId(mission.getMissionId())
            .eventType(MissionEventType.MISSION_CREATED)
            .requesterId(mission.getRequesterId())
            .timestamp(new Date())
            .build();
        
        kafkaTemplate.send("mission-events", event);
    }
}
```

## DTOs

### CreateMissionRequest
```java
public class CreateMissionRequest {
    @NotNull private UUID skillId;
    @NotBlank private String title;
    @NotBlank private String description;
    @NotNull private Date scheduledDate;
    @NotNull private Integer duration;
    @NotNull private Integer creditCost;
}
```

### MissionResponse
```java
public class MissionResponse {
    private UUID missionId;
    private UUID skillId;
    private String skillTitle;
    private UUID requesterId;
    private String requesterName;
    private UUID helperId;
    private String helperName;
    private String title;
    private String description;
    private MissionStatus status;
    private Date scheduledDate;
    private Integer duration;
    private Integer creditCost;
    private Double latitude;
    private Double longitude;
    private String location;
    private Date createdAt;
    private Date acceptedAt;
    private Date completedAt;
}
```

## Error Handling

### Custom Exceptions
```java
public class MissionNotFoundException extends RuntimeException {}
public class InsufficientCreditsException extends RuntimeException {}
public class UnauthorizedMissionAccessException extends RuntimeException {}
public class InvalidMissionStatusException extends RuntimeException {}
public class InvalidOtpException extends RuntimeException {}
public class OtpExpiredException extends RuntimeException {}
```

### Global Exception Handler
```java
@RestControllerAdvice
public class MissionExceptionHandler {
    @ExceptionHandler(MissionNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(MissionNotFoundException e) {
        return ResponseEntity.status(404).body(new ErrorResponse(e.getMessage()));
    }
    
    @ExceptionHandler(InsufficientCreditsException.class)
    public ResponseEntity<ErrorResponse> handleInsufficientCredits(InsufficientCreditsException e) {
        return ResponseEntity.status(402).body(new ErrorResponse(e.getMessage()));
    }
}
```

## Testing Strategy

### Unit Tests
- Service layer logic
- OTP generation and validation
- Status transitions
- Credit calculations

### Integration Tests
- MongoDB operations
- Redis OTP storage
- Kafka event publishing
- Feign client calls

### Test Scenarios
1. Create mission with sufficient credits
2. Create mission with insufficient credits (should fail)
3. Accept mission by skill owner
4. Accept mission by non-owner (should fail)
5. Generate and validate OTP successfully
6. Validate expired OTP (should fail)
7. Cancel mission and verify refund
8. Complete mission and verify credit transfer

## Security

### Authorization Rules
- **Create**: Any authenticated user
- **Accept**: Only skill owner
- **Reject**: Only skill owner
- **Cancel**: Requester or helper
- **Generate OTP**: Only helper
- **Validate OTP**: Only requester

### JWT Validation
- API Gateway validates JWT
- Extracts userId and adds X-User-Id header
- Mission service trusts X-User-Id header

## Performance Considerations

### Indexes
```java
@Indexed private UUID skillId;
@Indexed private UUID requesterId;
@Indexed private UUID helperId;
@Indexed private MissionStatus status;
@CompoundIndex(def = "{'requesterId': 1, 'status': 1}")
@CompoundIndex(def = "{'helperId': 1, 'status': 1}")
```

### Caching
- Cache skill details (5 minutes)
- Cache user details (5 minutes)

### Async Processing
- Kafka event publishing is async
- Credit operations are sync (critical)

## Monitoring

### Metrics to Track
- Mission creation rate
- Mission completion rate
- Average mission duration
- OTP validation success rate
- Credit transaction volume
- Failed credit operations

### Logs
- Mission state changes
- Credit transactions
- OTP generation/validation
- Kafka event publishing
- Feign client errors

## Next Steps

1. Implement Mission entity and repository
2. Create DTOs and mappers
3. Implement OTP service with Redis
4. Create Feign clients for User/Skill services
5. Implement mission service logic
6. Add Kafka event publishing
7. Create REST controllers
8. Add validation and error handling
9. Write unit and integration tests
10. Update API Gateway routing
