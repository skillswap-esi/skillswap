# SkillSwap System Architecture

Complete architecture documentation for the SkillSwap microservices platform.

## Table of Contents
1. [Overview](#overview)
2. [System Diagram](#system-diagram)
3. [Services](#services)
4. [Data Flow](#data-flow)
5. [Security](#security)
6. [Communication](#communication)
7. [Deployment](#deployment)

## Overview

SkillSwap is a skill exchange platform built with microservices architecture, enabling users to share and learn skills through missions with credit-based transactions.

### Technology Stack
- **Backend**: Spring Boot 3.3.4, Java 17
- **Databases**: MongoDB Atlas (cloud), Redis (Docker)
- **Messaging**: Apache Kafka (Docker)
- **API Gateway**: Spring Cloud Gateway
- **Authentication**: Firebase Auth + JWT
- **Mobile**: Flutter
- **Containerization**: Docker

## System Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Client Layer                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐         ┌──────────────┐                         │
│  │   Flutter    │         │     Web      │                         │
│  │   Mobile     │         │   Browser    │                         │
│  │   (Port N/A) │         │  (Port N/A)  │                         │
│  └──────┬───────┘         └──────┬───────┘                         │
│         │                        │                                  │
│         └────────────┬───────────┘                                  │
│                      │                                               │
└──────────────────────┼───────────────────────────────────────────────┘
                       │ HTTPS/JWT
                       │
┌──────────────────────▼───────────────────────────────────────────────┐
│                      Gateway Layer                                    │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│              ┌─────────────────────────────┐                         │
│              │     API Gateway             │                         │
│              │     Port: 8080              │                         │
│              │  - JWT Validation           │                         │
│              │  - Routing                  │                         │
│              │  - CORS                     │                         │
│              │  - Load Balancing           │                         │
│              └────────────┬────────────────┘                         │
│                           │                                           │
└───────────────────────────┼───────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼──────┐  ┌────────▼────────┐
│                │  │             │  │                  │
│  User Service  │  │Skill Service│  │ Mission Service  │
│   Port: 8081   │  │ Port: 8082  │  │   Port: 8083     │
│                │  │             │  │                  │
│ - Auth         │  │ - CRUD      │  │ - Lifecycle      │
│ - Profile      │  │ - Search    │  │ - OTP            │
│ - Credits      │  │ - Geo       │  │ - Credits        │
│ - Firebase     │  │             │  │ - Events         │
│                │  │             │  │                  │
└───────┬────────┘  └──────┬──────┘  └────────┬─────────┘
        │                  │                   │
        │                  │                   │
        │                  │         ┌─────────▼──────────┐
        │                  │         │ Notification       │
        │                  │         │ Service            │
        │                  │         │ Port: 8084         │
        │                  │         │                    │
        │                  │         │ - FCM              │
        │                  │         │ - Kafka Consumer   │
        │                  │         │ - History          │
        │                  │         └─────────┬──────────┘
        │                  │                   │
┌───────▼──────────────────▼───────────────────▼──────────┐
│                  Infrastructure Layer                    │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   MongoDB    │  │    Redis     │  │    Kafka     │  │
│  │   Atlas      │  │   Docker     │  │   Docker     │  │
│  │   (Cloud)    │  │   :6379      │  │   :9092      │  │
│  │              │  │              │  │              │  │
│  │ - users      │  │ - OTP codes  │  │ - Events     │  │
│  │ - skills     │  │ - Cache      │  │ - Topics     │  │
│  │ - missions   │  │              │  │              │  │
│  │ - notifs     │  │              │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Services

### 1. API Gateway (Port 8080)

**Purpose**: Single entry point for all client requests

**Responsibilities**:
- JWT token validation
- Request routing to microservices
- CORS handling
- Load balancing
- Rate limiting (future)

**Technology**:
- Spring Cloud Gateway
- JWT validation filter
- Route configuration

**Routes**:
```
/api/auth/**        → User Service (public)
/api/users/**       → User Service (protected)
/api/skills/**      → Skill Service (protected)
/api/missions/**    → Mission Service (protected)
/api/notifications/** → Notification Service (protected)
```

**Security Flow**:
1. Client sends request with JWT token
2. Gateway validates JWT
3. Gateway extracts userId from token
4. Gateway adds X-User-Id header
5. Gateway forwards to microservice
6. Microservice trusts X-User-Id header

---

### 2. User Service (Port 8081)

**Purpose**: User management and authentication

**Database**: MongoDB Atlas (`skillswap-users`)

**Key Features**:
- Firebase Authentication integration
- JWT token generation
- User profile management
- Credit system (earn/spend)
- Phone verification with bonus credits

**Endpoints**:
```
POST   /api/auth/register          - Register new user
POST   /api/auth/login             - Login with Firebase
GET    /api/users/{id}             - Get user profile
PUT    /api/users/{id}             - Update profile
POST   /api/users/{id}/credits/debit  - Debit credits
POST   /api/users/{id}/credits/credit - Credit credits
```

**Data Model**:
```java
User {
  userId: UUID
  firebaseUid: String
  email: String
  fullName: String
  phoneNumber: String
  avatar: String
  credits: Integer
  helperScore: Integer
  phoneVerified: Boolean
  createdAt: Date
}
```

---

### 3. Skill Service (Port 8082)

**Purpose**: Skill management with geolocation

**Database**: MongoDB Atlas (`skillswap-skills`)

**Key Features**:
- CRUD operations for skills
- Geospatial search (MongoDB 2dsphere index)
- Category filtering
- User enrichment (optional)
- Distance calculation

**Endpoints**:
```
POST   /api/skills                 - Create skill
GET    /api/skills/{id}            - Get skill
GET    /api/skills/near            - Search nearby skills
GET    /api/skills/user/{userId}   - Get user's skills
PUT    /api/skills/{id}            - Update skill
DELETE /api/skills/{id}            - Delete skill
```

**Data Model**:
```java
Skill {
  skillId: UUID
  ownerId: UUID
  title: String
  description: String
  category: String
  geoPoint: GeoJsonPoint [lng, lat]
  active: Boolean
  createdAt: Date
}
```

**Categories**:
- BRICOLAGE, SCOLAIRE, SPORT, INFORMATIQUE
- CUISINE, JARDINAGE, MUSIQUE, LANGUES, ART, AUTRE

---

### 4. Mission Service (Port 8083)

**Purpose**: Mission lifecycle and OTP validation

**Databases**: 
- MongoDB Atlas (`skillswap-missions`)
- Redis (OTP storage)

**Key Features**:
- Mission creation with credit debit
- Accept/Reject by skill owner
- OTP generation (6 digits, 5-minute expiration)
- OTP validation for completion
- Credit transfer on completion
- Kafka event publishing
- Cancellation with refunds

**Endpoints**:
```
POST   /api/missions                    - Create mission
GET    /api/missions/{id}               - Get mission
GET    /api/missions/user/{userId}      - Get user missions
POST   /api/missions/{id}/accept        - Accept mission
POST   /api/missions/{id}/reject        - Reject mission
POST   /api/missions/{id}/cancel        - Cancel mission
POST   /api/missions/{id}/start         - Start mission
POST   /api/missions/{id}/generate-otp  - Generate OTP
POST   /api/missions/{id}/validate-otp  - Validate OTP
```

**Data Model**:
```java
Mission {
  missionId: UUID
  skillId: UUID
  requesterId: UUID
  helperId: UUID
  title: String
  description: String
  status: MissionStatus
  scheduledDate: Date
  duration: Integer
  creditCost: Integer
  geoPoint: GeoJsonPoint
  createdAt: Date
  acceptedAt: Date
  completedAt: Date
}
```

**Status Flow**:
```
PENDING → ACCEPTED → IN_PROGRESS → COMPLETED
   ↓          ↓            ↓
REJECTED  CANCELLED    CANCELLED
```

**OTP Flow**:
1. Mission IN_PROGRESS
2. Helper generates OTP → Stored in Redis (5 min)
3. Helper shares OTP with requester
4. Requester validates OTP
5. Credits transferred to helper
6. Mission marked COMPLETED
7. OTP deleted from Redis

---

### 5. Notification Service (Port 8084)

**Purpose**: Push notifications and history

**Database**: MongoDB Atlas (`skillswap-notifications`)

**Key Features**:
- Kafka event consumption
- Firebase Cloud Messaging (FCM)
- Notification history
- Read/unread tracking
- FCM token management

**Endpoints**:
```
GET    /api/notifications              - Get all notifications
GET    /api/notifications/unread       - Get unread
GET    /api/notifications/unread/count - Get unread count
POST   /api/notifications/{id}/read    - Mark as read
POST   /api/notifications/read-all     - Mark all as read
DELETE /api/notifications/{id}         - Delete notification
POST   /api/notifications/token        - Register FCM token
DELETE /api/notifications/token        - Unregister FCM token
```

**Data Model**:
```java
Notification {
  notificationId: UUID
  userId: UUID
  type: NotificationType
  title: String
  message: String
  data: Map<String, Object>
  read: Boolean
  sentAt: Date
  readAt: Date
  fcmSent: Boolean
  fcmMessageId: String
}
```

**Event Handling**:
- MISSION_CREATED → Notify skill owner
- MISSION_ACCEPTED → Notify requester
- MISSION_REJECTED → Notify requester
- MISSION_STARTED → Notify both parties
- MISSION_COMPLETED → Notify both + credit notification
- MISSION_CANCELLED → Notify both parties

---

## Data Flow

### Complete Mission Flow

```
1. CREATE MISSION
   Client → Gateway → Mission Service
   ├─ Verify skill exists (Skill Service)
   ├─ Check credits (User Service)
   ├─ Debit credits (User Service)
   ├─ Create mission (MongoDB)
   └─ Publish MissionCreatedEvent (Kafka)
        └─ Notification Service → Send FCM to helper

2. ACCEPT MISSION
   Client → Gateway → Mission Service
   ├─ Verify skill owner
   ├─ Update mission status
   └─ Publish MissionAcceptedEvent (Kafka)
        └─ Notification Service → Send FCM to requester

3. START MISSION
   Client → Gateway → Mission Service
   ├─ Update mission status
   └─ Publish MissionStartedEvent (Kafka)
        └─ Notification Service → Send FCM to both

4. GENERATE OTP
   Client → Gateway → Mission Service
   └─ Generate 6-digit code → Store in Redis (5 min)

5. VALIDATE OTP
   Client → Gateway → Mission Service
   ├─ Validate OTP from Redis
   ├─ Credit helper (User Service)
   ├─ Update mission status
   ├─ Delete OTP from Redis
   └─ Publish MissionCompletedEvent (Kafka)
        └─ Notification Service → Send FCM to both
```

### Skill Search Flow

```
Client → Gateway → Skill Service
├─ Query MongoDB with geospatial index
├─ Filter by category (optional)
├─ Calculate distances
├─ Enrich with user data (optional, User Service)
└─ Return sorted by distance
```

## Security

### Authentication Flow

```
1. User registers/logs in via Firebase
2. Mobile app gets Firebase ID token
3. Mobile app calls /api/auth/login with Firebase token
4. User Service validates Firebase token
5. User Service generates JWT token
6. Mobile app stores JWT token
7. Mobile app includes JWT in all requests
8. API Gateway validates JWT
9. API Gateway extracts userId
10. API Gateway adds X-User-Id header
11. Microservice trusts X-User-Id header
```

### Security Layers

**Layer 1: Firebase Authentication**
- Email/password authentication
- Phone number verification
- Social login (Google, Facebook)

**Layer 2: JWT Tokens**
- Generated by User Service
- Validated by API Gateway
- Contains userId and expiration
- Secret key: `skillswap-secret-key-change-this-in-production-2024`

**Layer 3: API Gateway**
- Validates JWT on every request
- Adds X-User-Id header
- Strips /api prefix
- Routes to microservices

**Layer 4: Microservices**
- Trust X-User-Id header from Gateway
- Perform authorization checks
- Verify ownership (e.g., only skill owner can accept mission)

### Authorization Rules

| Action | Rule |
|--------|------|
| Create Mission | Any authenticated user with credits |
| Accept Mission | Only skill owner |
| Reject Mission | Only skill owner |
| Cancel Mission | Requester or helper |
| Generate OTP | Only helper |
| Validate OTP | Only requester |
| Update Skill | Only skill owner |
| Delete Skill | Only skill owner |

## Communication

### Synchronous (REST/Feign)

**Mission Service → User Service**
```java
@FeignClient(name = "service-user", url = "http://localhost:8081")
public interface UserClient {
    @GetMapping("/api/users/{userId}")
    UserDto getUserById(@PathVariable UUID userId);
    
    @PostMapping("/api/users/{userId}/credits/debit")
    void debitCredits(@PathVariable UUID userId, @RequestParam Integer amount);
    
    @PostMapping("/api/users/{userId}/credits/credit")
    void creditCredits(@PathVariable UUID userId, @RequestParam Integer amount);
}
```

**Mission Service → Skill Service**
```java
@FeignClient(name = "service-skill", url = "http://localhost:8082")
public interface SkillClient {
    @GetMapping("/api/skills/{skillId}")
    SkillDto getSkillById(@PathVariable UUID skillId);
}
```

### Asynchronous (Kafka)

**Topic**: `mission-events`

**Producer**: Mission Service
**Consumer**: Notification Service

**Event Types**:
- MISSION_CREATED
- MISSION_ACCEPTED
- MISSION_REJECTED
- MISSION_STARTED
- MISSION_COMPLETED
- MISSION_CANCELLED

**Event Structure**:
```json
{
  "missionId": "uuid",
  "skillId": "uuid",
  "requesterId": "uuid",
  "helperId": "uuid",
  "eventType": "MISSION_COMPLETED",
  "missionTitle": "Guitar Lessons",
  "creditAmount": 10,
  "timestamp": "2026-01-23T20:00:00Z",
  "metadata": {
    "reason": "Schedule conflict"
  }
}
```

## Deployment

### Local Development

```bash
# 1. Start Docker services
cd skillswap-backend
docker-compose up -d

# 2. Start services
cd skillswap-api-gateway && mvn spring-boot:run &
cd skillswap-service-user && mvn spring-boot:run &
cd skillswap-service-skill && mvn spring-boot:run &
cd skillswap-service-mission && mvn spring-boot:run &
cd skillswap-service-notification && mvn spring-boot:run &
```

### Service Dependencies

```
API Gateway (8080)
├─ No dependencies

User Service (8081)
├─ MongoDB Atlas
└─ Firebase Auth

Skill Service (8082)
├─ MongoDB Atlas
└─ User Service (optional, for enrichment)

Mission Service (8083)
├─ MongoDB Atlas
├─ Redis
├─ Kafka
├─ User Service
└─ Skill Service

Notification Service (8084)
├─ MongoDB Atlas
├─ Kafka
└─ Firebase Cloud Messaging
```

### Startup Order

1. Docker services (Kafka, Redis)
2. User Service (8081)
3. Skill Service (8082)
4. Mission Service (8083)
5. Notification Service (8084)
6. API Gateway (8080)

### Health Checks

```bash
# API Gateway
curl http://localhost:8080/actuator/health

# User Service
curl http://localhost:8081/actuator/health

# Skill Service
curl http://localhost:8082/actuator/health

# Mission Service
curl http://localhost:8083/actuator/health

# Notification Service
curl http://localhost:8084/actuator/health
```

## Monitoring

### Kafka UI
- URL: http://localhost:8090
- Monitor topics, messages, consumer lag

### Redis Commander
- URL: http://localhost:8091
- View OTP codes, cache data

### MongoDB Atlas
- URL: https://cloud.mongodb.com
- Monitor queries, performance, storage

### Spring Boot Actuator
- Health: `/actuator/health`
- Metrics: `/actuator/metrics`
- Info: `/actuator/info`

## Scalability

### Horizontal Scaling
- Each microservice can be scaled independently
- API Gateway handles load balancing
- Kafka partitions for parallel processing
- MongoDB sharding for large datasets

### Caching Strategy
- Redis for OTP codes (5-minute TTL)
- User data caching (future)
- Skill search results caching (future)

### Database Optimization
- MongoDB indexes on frequently queried fields
- Geospatial index for location queries
- Compound indexes for complex queries

## Future Enhancements

1. **Service Discovery**: Eureka/Consul
2. **Config Server**: Centralized configuration
3. **Circuit Breaker**: Resilience4j
4. **Distributed Tracing**: Zipkin/Jaeger
5. **Centralized Logging**: ELK Stack
6. **API Documentation**: Swagger/OpenAPI
7. **Rate Limiting**: Redis-based
8. **Caching**: Redis for frequently accessed data
9. **Message Queue**: RabbitMQ for reliable messaging
10. **Kubernetes**: Container orchestration

## Conclusion

SkillSwap uses a modern microservices architecture with:
- ✅ Independent, scalable services
- ✅ Event-driven communication
- ✅ Cloud-native databases
- ✅ Secure authentication/authorization
- ✅ Real-time notifications
- ✅ Geospatial capabilities
- ✅ Credit-based economy
- ✅ OTP validation for trust
