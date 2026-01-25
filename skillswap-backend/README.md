# SkillSwap Backend - Microservices Architecture

## 📋 Overview

SkillSwap Backend is a microservices-based platform built with Spring Boot that enables users to exchange skills through a credit-based mission system. The architecture follows domain-driven design principles with event-driven communication.

## 🏗️ Architecture

### Microservices Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Gateway (8080)                       │
│                    JWT Validation & Routing                      │
└────────────┬────────────────────────────────────────────────────┘
             │
    ┌────────┼────────┬────────────┬────────────┐
    │        │        │            │            │
    ▼        ▼        ▼            ▼            ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐
│ User   │ │ Skill  │ │Mission │ │Notif.  │ │  Common    │
│Service │ │Service │ │Service │ │Service │ │  Library   │
│ 8081   │ │ 8082   │ │ 8083   │ │ 8084   │ │            │
└───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ └────────────┘
    │          │          │          │
    ▼          ▼          ▼          │
┌─────────────────────────────────┐  │
│      MongoDB Atlas (Cloud)       │  │
│  ┌──────────┬──────────┬──────┐ │  │
│  │  users   │  skills  │missions│ │  │
│  └──────────┴──────────┴──────┘ │  │
└─────────────────────────────────┘  │
                                     │
    ┌────────────────────────────────┤
    │                                │
    ▼                                ▼
┌─────────┐                    ┌──────────┐
│  Redis  │                    │  Kafka   │
│  6379   │                    │  9092    │
│  (OTP)  │                    │ (Events) │
└─────────┘                    └──────────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │  Firebase   │
                              │  (FCM Push) │
                              └─────────────┘
```

## 🎯 Services Overview

### 1. API Gateway (Port 8080)
**Purpose**: Single entry point for all client requests

**Responsibilities**:
- Route requests to appropriate microservices
- JWT token validation
- Add X-User-Id header for downstream services
- CORS configuration
- Request/response logging

**Technology Stack**:
- Spring Cloud Gateway
- JWT (io.jsonwebtoken)
- Spring Security

**Key Features**:
- Path-based routing (`/api/users/**` → User Service)
- Token extraction and validation
- User ID propagation via headers
- Centralized security

### 2. User Service (Port 8081)
**Purpose**: User management, authentication, and credit system

**Responsibilities**:
- User registration with Firebase
- Phone verification (OTP)
- JWT token generation
- Profile management (CRUD)
- Credit balance management (debit/credit)
- Helper Score calculation
- FCM token storage for push notifications
- Admin authentication

**Technology Stack**:
- Spring Boot 3.3
- Spring Data MongoDB
- Firebase Admin SDK
- JWT (io.jsonwebtoken)
- Spring Security

**Database**: MongoDB Atlas - `skillswap-users` database

**Key Entities**:
```java
User {
  userId: UUID
  firebaseUid: String
  email: String
  phoneNumber: String
  fullName: String
  phoneVerified: Boolean
  creditsBalance: Integer
  helperScore: Float
  avatar: String
  roles: List<String>
  fcmTokens: List<String>
  createdAt: Date
  updatedAt: Date
}
```

**API Endpoints**:
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with Firebase token
- `POST /api/auth/admin/login` - Admin login
- `GET /api/users/{id}` - Get user profile
- `PUT /api/users/{id}` - Update profile
- `POST /api/users/{id}/credits/debit` - Debit credits
- `POST /api/users/{id}/credits/credit` - Credit credits
- `POST /api/users/{id}/fcm-token` - Register FCM token

### 3. Skill Service (Port 8082)
**Purpose**: Skill management and geolocation-based search

**Responsibilities**:
- Skill CRUD operations
- Geospatial queries (find skills within radius)
- Category-based filtering
- Skill ownership validation
- User enrichment (fetch owner details)

**Technology Stack**:
- Spring Boot 3.3
- Spring Data MongoDB (with GeoJSON support)
- OpenFeign (inter-service communication)
- Spring Cloud LoadBalancer

**Database**: MongoDB Atlas - `skillswap-skills` database

**Key Entities**:
```java
Skill {
  skillId: UUID
  ownerId: UUID
  category: SkillCategory (enum)
  title: String
  description: String
  geoPoint: GeoJsonPoint [longitude, latitude]
  active: Boolean
  createdAt: Date
  updatedAt: Date
}
```

**Geospatial Features**:
- 2dsphere index on `geoPoint` field
- `$near` query for proximity search
- Distance calculation in meters
- Default search radius: 15km

**API Endpoints**:
- `POST /api/skills` - Create skill
- `GET /api/skills/{id}` - Get skill details
- `GET /api/skills/near?lat={lat}&lng={lng}&radius={r}&category={cat}` - Search nearby
- `GET /api/skills/user/{userId}` - Get user's skills
- `PUT /api/skills/{id}` - Update skill
- `DELETE /api/skills/{id}` - Delete skill

### 4. Mission Service (Port 8083)
**Purpose**: Mission lifecycle management and OTP validation

**Responsibilities**:
- Mission creation and booking
- Mission status management (PENDING → ACCEPTED → IN_PROGRESS → COMPLETED)
- OTP generation and validation (Redis)
- Credit transfer coordination
- Partner places management
- Kafka event publishing
- User and skill enrichment

**Technology Stack**:
- Spring Boot 3.3
- Spring Data MongoDB
- Spring Data Redis (OTP storage)
- Spring Kafka (event publishing)
- OpenFeign (inter-service communication)

**Database**: MongoDB Atlas - `skillswap-missions` database

**Cache**: Redis (OTP codes with 5-minute TTL)

**Key Entities**:
```java
Mission {
  missionId: UUID
  skillId: UUID
  requesterId: UUID
  providerId: UUID
  title: String
  description: String
  status: MissionStatus
  scheduledDate: Date
  duration: Integer (minutes)
  creditCost: Integer
  meetingPoint: {
    latitude: Double
    longitude: Double
    partnerPlaceId: UUID
  }
  createdAt: Date
  acceptedAt: Date
  startedAt: Date
  completedAt: Date
  cancelledAt: Date
}

PartnerPlace {
  placeId: UUID
  name: String
  address: String
  latitude: Double
  longitude: Double
  category: String
  active: Boolean
}
```

**Mission Status Flow**:
```
PENDING → ACCEPTED → IN_PROGRESS → COMPLETED
   ↓          ↓            ↓
REJECTED  CANCELLED    CANCELLED
```

**OTP Workflow**:
1. Provider generates OTP (6 digits)
2. Stored in Redis with 5-minute expiration
3. Requester validates OTP
4. Mission status → COMPLETED
5. Credits transferred

**API Endpoints**:
- `POST /api/missions` - Create mission
- `GET /api/missions/{id}` - Get mission details
- `GET /api/missions/user/{userId}?role={REQUESTER|HELPER}&status={status}` - Get user missions
- `POST /api/missions/{id}/accept` - Accept mission (provider)
- `POST /api/missions/{id}/reject` - Reject mission (provider)
- `POST /api/missions/{id}/start` - Start mission (provider)
- `POST /api/missions/{id}/generate-otp` - Generate OTP (provider)
- `POST /api/missions/{id}/validate-otp` - Validate OTP (requester)
- `POST /api/missions/{id}/cancel` - Cancel mission
- `GET /api/missions/partner-places` - Get partner places
- `POST /api/missions/partner-places` - Create partner place

### 5. Notification Service (Port 8084)
**Purpose**: Push notification delivery via Firebase Cloud Messaging

**Responsibilities**:
- Listen to Kafka events
- Send FCM push notifications
- Handle notification templates
- Manage notification delivery status

**Technology Stack**:
- Spring Boot 3.3
- Spring Kafka (event consumer)
- Firebase Admin SDK (FCM)

**No Database**: Notifications are sent via FCM and stored in Firestore by mobile app

**Kafka Event Listeners**:
- `MISSION_CREATED` → Notify skill owner
- `MISSION_ACCEPTED` → Notify requester
- `MISSION_REJECTED` → Notify requester
- `MISSION_STARTED` → Notify requester
- `MISSION_COMPLETED` → Notify both users
- `MISSION_CANCELLED` → Notify affected user
- `OTP_GENERATED` → Notify requester

**Notification Flow**:
```
Mission Service → Kafka Event → Notification Service → FCM → Mobile App
```

### 6. Common Library
**Purpose**: Shared utilities and DTOs

**Contents**:
- Common DTOs
- Utility classes
- Shared constants
- Exception classes

## 🔄 Event-Driven Architecture

### Kafka Topics

**Topic**: `mission-events`

**Event Structure**:
```json
{
  "missionId": "uuid",
  "skillId": "uuid",
  "requesterId": "uuid",
  "providerId": "uuid",
  "eventType": "MISSION_COMPLETED",
  "missionTitle": "Guitar Lessons",
  "creditAmount": 10,
  "timestamp": "2026-01-24T20:00:00Z",
  "metadata": {
    "skillOwnerId": "uuid",
    "requesterName": "John Doe",
    "providerName": "Jane Smith"
  }
}
```

**Event Types**:
- `MISSION_CREATED` - New mission requested
- `MISSION_ACCEPTED` - Provider accepted
- `MISSION_REJECTED` - Provider rejected
- `MISSION_STARTED` - Mission in progress
- `MISSION_COMPLETED` - Mission finished, credits transferred
- `MISSION_CANCELLED` - Mission cancelled
- `OTP_GENERATED` - OTP code generated

## 💾 Data Storage

### MongoDB Atlas (Cloud)
**Databases**:
- `skillswap-users` - User profiles, credits, FCM tokens
- `skillswap-skills` - Skills with geospatial data
- `skillswap-missions` - Missions and partner places

**Connection String Format**:
```
mongodb+srv://username:password@cluster.xxxxx.mongodb.net/database?retryWrites=true&w=majority
```

### Redis (Docker)
**Purpose**: Temporary OTP storage

**Configuration**:
- Host: localhost
- Port: 6379
- TTL: 5 minutes for OTP codes

**Key Format**: `mission:{missionId}:otp`

### Firestore (Firebase)
**Purpose**: Real-time chat and notification history (managed by mobile app)

**Collections**:
- `chat_threads` - Chat conversations
- `notifications` - Notification history

## 🔐 Security

### Authentication Flow
```
1. User registers/logs in via Firebase
2. Mobile app gets Firebase ID token
3. App calls /api/auth/login with Firebase token
4. User Service validates token with Firebase
5. User Service generates JWT token
6. App stores JWT token
7. App includes JWT in Authorization header
8. API Gateway validates JWT
9. Gateway extracts userId and adds X-User-Id header
10. Microservices trust X-User-Id header
```

### JWT Token Structure
```json
{
  "sub": "user-uuid",
  "email": "user@example.com",
  "roles": ["ROLE_USER"],
  "iat": 1706140800,
  "exp": 1706227200
}
```

### Authorization Rules
- **Create Mission**: Any authenticated user with sufficient credits
- **Accept/Reject Mission**: Only skill owner (provider)
- **Cancel Mission**: Requester or provider
- **Generate OTP**: Only provider
- **Validate OTP**: Only requester
- **Update/Delete Skill**: Only skill owner

## 🛠️ Technology Stack

### Core Technologies
- **Java**: 17
- **Spring Boot**: 3.3.x
- **Spring Cloud**: 2023.0.x
- **Maven**: 3.8+

### Frameworks & Libraries
- **Spring Data MongoDB**: NoSQL data access
- **Spring Data Redis**: Caching and OTP storage
- **Spring Kafka**: Event streaming
- **Spring Cloud Gateway**: API routing
- **Spring Security**: Authentication & authorization
- **OpenFeign**: Inter-service communication
- **Firebase Admin SDK**: Authentication & FCM
- **JWT (jjwt)**: Token generation/validation
- **Lombok**: Boilerplate reduction
- **SpringDoc OpenAPI**: API documentation

### Infrastructure
- **MongoDB Atlas**: Cloud database
- **Redis**: In-memory cache (Docker)
- **Kafka**: Event streaming (Docker)
- **Zookeeper**: Kafka coordination (Docker)
- **Docker Compose**: Local infrastructure

## 🚀 Quick Start

### Prerequisites
- Java 17+
- Maven 3.8+
- Docker & Docker Compose
- MongoDB Atlas account
- Firebase project

### 1. Start Infrastructure
```bash
cd skillswap-backend
docker-compose up -d
```

This starts:
- Redis (port 6379)
- Zookeeper (port 2181)
- Kafka (port 9092)

### 2. Configure MongoDB Atlas
1. Create free cluster at https://cloud.mongodb.com
2. Create databases: `skillswap-users`, `skillswap-skills`, `skillswap-missions`
3. Create database user
4. Whitelist IP: `0.0.0.0/0`
5. Update connection strings in each service's `application.yml`

### 3. Configure Firebase
1. Download `firebase-service-account.json` from Firebase Console
2. Place in:
   - `skillswap-service-user/src/main/resources/`
   - `skillswap-service-notification/src/main/resources/`

### 4. Start Services
Open 5 terminals:

```bash
# Terminal 1 - API Gateway
cd skillswap-api-gateway
mvnw spring-boot:run

# Terminal 2 - User Service
cd skillswap-service-user
mvnw spring-boot:run

# Terminal 3 - Skill Service
cd skillswap-service-skill
mvnw spring-boot:run

# Terminal 4 - Mission Service
cd skillswap-service-mission
mvnw spring-boot:run

# Terminal 5 - Notification Service
cd skillswap-service-notification
mvnw spring-boot:run
```

### 5. Verify Services
```bash
# Health checks
curl http://localhost:8080/actuator/health  # API Gateway
curl http://localhost:8081/actuator/health  # User Service
curl http://localhost:8082/actuator/health  # Skill Service
curl http://localhost:8083/actuator/health  # Mission Service
curl http://localhost:8084/actuator/health  # Notification Service
```

### 6. Access Swagger Documentation
- User Service: http://localhost:8081/swagger-ui.html
- Skill Service: http://localhost:8082/swagger-ui.html
- Mission Service: http://localhost:8083/swagger-ui.html
- Notification Service: http://localhost:8084/swagger-ui.html

## 📊 Complete User Scenarios

### S1 - Registration with Phone Verification
1. User submits registration form
2. User Service creates account in MongoDB
3. Firebase sends OTP to phone
4. User enters OTP
5. User Service verifies OTP
6. Credits bonus added (50 credits)
7. Welcome notification sent via Kafka

### S2 - Publish a Skill
1. User creates skill with GPS location
2. Skill Service saves to MongoDB with GeoJSON point
3. 2dsphere index enables geospatial queries
4. Skill appears in nearby searches

### S3 - Search Skills by Location
1. Mobile app detects user location
2. Skill Service executes `$near` query
3. Results sorted by distance and Helper Score
4. User enrichment via Feign client
5. Skills displayed on map and list

### S4 - Request Mission
1. Requester selects skill
2. Mission Service creates mission (status: PENDING)
3. Credits debited from requester
4. Kafka event: MISSION_CREATED
5. Notification Service sends FCM to skill owner

### S5 - Accept Mission
1. Provider receives notification
2. Provider clicks "Accept"
3. Mission Service updates status to ACCEPTED
4. Kafka event: MISSION_ACCEPTED
5. Notification sent to requester

### S6 - OTP Validation
1. Provider clicks "Generate OTP"
2. Mission Service generates 6-digit code
3. Code stored in Redis (5-minute TTL)
4. Provider shows code to requester
5. Requester enters code
6. Mission Service validates OTP
7. Status → COMPLETED
8. Credits transferred (debit requester, credit provider)
9. Helper Score updated
10. Kafka event: MISSION_COMPLETED
11. Both users notified

## 🔧 Configuration

### Environment Variables
Each service supports environment variables for configuration:

```bash
# MongoDB
MONGODB_URI=mongodb+srv://...

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Kafka
KAFKA_BOOTSTRAP_SERVERS=localhost:9092

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRATION=86400000

# Firebase
FIREBASE_CREDENTIALS_PATH=classpath:firebase-service-account.json
```

### Application Profiles
- `default` - Local development
- `prod` - Production environment

## 🐛 Troubleshooting

### MongoDB Connection Issues
```bash
# Check connection string format
# Verify IP whitelist (0.0.0.0/0)
# Test connection from MongoDB Compass
```

### Kafka Not Available
```bash
# Wait 30 seconds for Kafka to start
docker-compose ps
docker-compose logs kafka
```

### Redis Connection Refused
```bash
docker-compose ps redis
docker exec skillswap-redis redis-cli ping
```

### Skills Not Saving (Index Error)
```bash
# Drop geoPoint index in MongoDB Atlas
# Restart Skill Service to recreate index
```

## 📈 Monitoring & Observability

### Health Endpoints
All services expose Spring Boot Actuator endpoints:
- `/actuator/health` - Service health status
- `/actuator/info` - Service information
- `/actuator/metrics` - Service metrics

### Logging
- **Level**: DEBUG for application code, INFO for frameworks
- **Format**: JSON structured logging (production)
- **Destination**: Console (Docker logs)

### Metrics
- Request count and latency
- Database query performance
- Kafka message throughput
- Redis cache hit rate

## 🚢 Production Deployment

### Docker Build
```bash
# Build all services
mvn clean package -DskipTests

# Build Docker images
docker build -t skillswap-user-service:1.0.0 skillswap-service-user
docker build -t skillswap-skill-service:1.0.0 skillswap-service-skill
docker build -t skillswap-mission-service:1.0.0 skillswap-service-mission
docker build -t skillswap-notification-service:1.0.0 skillswap-service-notification
docker build -t skillswap-api-gateway:1.0.0 skillswap-api-gateway
```

### Environment Configuration
- Use environment variables for all secrets
- Configure MongoDB Atlas with proper security
- Enable Kafka authentication
- Use Redis password
- Configure CORS for production domains
- Enable HTTPS/TLS

### Scaling Considerations
- Each microservice can scale independently
- Use load balancer for API Gateway
- Kafka partitions for parallel processing
- MongoDB sharding for large datasets
- Redis cluster for high availability

## 📚 API Documentation

Complete API documentation available via Swagger UI when services are running.

### Swagger URLs
- User Service: http://localhost:8081/swagger-ui.html
- Skill Service: http://localhost:8082/swagger-ui.html
- Mission Service: http://localhost:8083/swagger-ui.html
- Notification Service: http://localhost:8084/swagger-ui.html

## 🤝 Contributing

### Code Style
- Follow Java naming conventions
- Use Lombok for boilerplate reduction
- Write meaningful commit messages
- Add JavaDoc for public APIs

### Testing
```bash
# Run unit tests
mvn test

# Run integration tests
mvn verify
```

## 📄 License

Private Project - All Rights Reserved

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Status**: Production Ready
