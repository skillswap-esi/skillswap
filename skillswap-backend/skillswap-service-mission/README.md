# Mission Service

Manages the complete lifecycle of skill exchange missions with OTP validation, credit management, and event publishing.

## Port: 8083

## Features

- Create missions from skills
- Accept/Reject missions by skill owners
- Start missions
- Generate OTP codes (stored in Redis, 5-minute expiration)
- Validate OTP to complete missions
- Cancel missions with refunds
- Credit management (debit on create, credit on complete)
- Kafka event publishing for notifications
- User data enrichment

## Tech Stack

- Spring Boot 3.3.4
- MongoDB (mission storage)
- Redis (OTP temporary storage)
- Kafka (event publishing)
- OpenFeign (inter-service communication)
- Spring Data MongoDB
- Spring Data Redis

## Dependencies

- **User Service** (8081): Credit operations, user data
- **Skill Service** (8082): Skill validation and data
- **MongoDB**: Mission persistence
- **Redis**: OTP storage
- **Kafka**: Event publishing

## Mission Status Flow

```
PENDING → ACCEPTED → IN_PROGRESS → COMPLETED
   ↓          ↓            ↓
REJECTED  CANCELLED    CANCELLED
```

## API Endpoints

All endpoints require JWT authentication via API Gateway (X-User-Id header).

### Create Mission
```
POST /api/missions
Headers: X-User-Id: {requesterId}
Body: {
  "skillId": "uuid",
  "title": "Need help with guitar",
  "description": "Learn basic chords",
  "scheduledDate": "2026-01-25T14:00:00Z",
  "duration": 60,
  "creditCost": 10
}
```

### Get Mission
```
GET /api/missions/{missionId}
```

### Get User Missions
```
GET /api/missions/user/{userId}?role=REQUESTER&status=PENDING
Query params:
  - role: REQUESTER or HELPER (optional)
  - status: PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED, REJECTED (optional)
```

### Accept Mission
```
POST /api/missions/{missionId}/accept
Headers: X-User-Id: {helperId}
```

### Reject Mission
```
POST /api/missions/{missionId}/reject
Headers: X-User-Id: {helperId}
Body: { "reason": "Not available" }
```

### Cancel Mission
```
POST /api/missions/{missionId}/cancel
Headers: X-User-Id: {userId}
Body: { "reason": "Schedule conflict" }
```

### Start Mission
```
POST /api/missions/{missionId}/start
Headers: X-User-Id: {userId}
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
```

## Business Logic

### Create Mission
1. Verify skill exists and is active
2. Verify requester has sufficient credits
3. Debit credits from requester
4. Create mission with PENDING status
5. Publish MissionCreatedEvent

### Accept Mission
1. Verify mission is PENDING
2. Verify user is skill owner
3. Set helperId and status to ACCEPTED
4. Publish MissionAcceptedEvent

### Reject Mission
1. Verify mission is PENDING
2. Verify user is skill owner
3. Refund credits to requester
4. Set status to REJECTED
5. Publish MissionRejectedEvent

### Start Mission
1. Verify mission is ACCEPTED
2. Verify user is requester or helper
3. Set status to IN_PROGRESS
4. Publish MissionStartedEvent

### Generate OTP
1. Verify mission is IN_PROGRESS
2. Verify user is helper
3. Generate 6-digit code
4. Store in Redis with 5-minute expiration

### Validate OTP
1. Verify mission is IN_PROGRESS
2. Verify user is requester
3. Validate OTP from Redis
4. Credit helper with mission cost
5. Set status to COMPLETED
6. Delete OTP from Redis
7. Publish MissionCompletedEvent

### Cancel Mission
1. Verify user is requester or helper
2. Cannot cancel if COMPLETED
3. Refund credits if PENDING or ACCEPTED
4. Delete OTP if exists
5. Set status to CANCELLED
6. Publish MissionCancelledEvent

## Configuration

### application.yml
```yaml
server:
  port: 8083

spring:
  data:
    mongodb:
      uri: mongodb+srv://...
    redis:
      host: localhost
      port: 6379
  kafka:
    bootstrap-servers: localhost:9092

user:
  service:
    url: http://localhost:8081

skill:
  service:
    url: http://localhost:8082

otp:
  expiration-minutes: 5
  length: 6

mission:
  enrich-with-user-data: true
```

## Kafka Events

Published to topic: `mission-events`

Event types:
- MISSION_CREATED
- MISSION_ACCEPTED
- MISSION_REJECTED
- MISSION_STARTED
- MISSION_COMPLETED
- MISSION_CANCELLED

## Security

- Authentication handled by API Gateway (JWT validation)
- API Gateway adds X-User-Id header
- Mission Service trusts X-User-Id header
- Authorization checks:
  - Create: Any authenticated user
  - Accept/Reject: Only skill owner
  - Cancel: Requester or helper
  - Generate OTP: Only helper
  - Validate OTP: Only requester

## Running the Service

### Prerequisites
- MongoDB running
- Redis running
- Kafka running (optional, for events)
- User Service running (8081)
- Skill Service running (8082)

### Start Service
```bash
cd skillswap-service-mission
mvn spring-boot:run
```

### With Docker
```bash
docker-compose up -d mongodb redis kafka
mvn spring-boot:run
```

## Testing

### Manual Testing
Use the provided Postman collection or curl commands.

### Example: Create Mission
```bash
curl -X POST http://localhost:8080/api/missions \
  -H "Authorization: Bearer {jwt-token}" \
  -H "Content-Type: application/json" \
  -d '{
    "skillId": "uuid",
    "title": "Need help with guitar",
    "description": "Learn basic chords",
    "scheduledDate": "2026-01-25T14:00:00Z",
    "duration": 60,
    "creditCost": 10
  }'
```

## Error Handling

- 400: Validation errors, invalid status, invalid OTP
- 402: Insufficient credits
- 403: Unauthorized access
- 404: Mission not found, skill not found
- 500: Internal server error

## Monitoring

Endpoints:
- Health: http://localhost:8083/actuator/health
- Metrics: http://localhost:8083/actuator/metrics

## Development

### Project Structure
```
src/main/java/com/skillswap/mission/
├── MissionServiceApplication.java
├── model/
│   └── Mission.java
├── dto/
│   ├── CreateMissionRequest.java
│   ├── MissionResponse.java
│   ├── OtpResponse.java
│   └── ValidateOtpRequest.java
├── enums/
│   ├── MissionStatus.java
│   └── MissionEventType.java
├── repositories/
│   └── MissionRepository.java
├── services/
│   ├── MissionService.java
│   ├── OtpService.java
│   └── MissionEventPublisher.java
├── controllers/
│   └── MissionController.java
├── client/
│   ├── UserClient.java
│   └── SkillClient.java
├── events/
│   └── MissionEvent.java
├── config/
│   ├── KafkaTopicConfig.java
│   └── RedisConfig.java
└── exceptions/
    ├── GlobalExceptionHandler.java
    └── ...
```

## Next Steps

1. Start MongoDB, Redis, and Kafka
2. Update MongoDB URI in application.yml
3. Start User and Skill services
4. Start Mission Service
5. Test endpoints via API Gateway (port 8080)
6. Implement Notification Service to consume events
