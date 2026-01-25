# SkillSwap Backend - Complete Documentation

## Overview

SkillSwap is a skill exchange platform where users can offer and request skills through missions, validated by OTP codes, with a credit-based economy.

## Architecture

**Microservices:**
- API Gateway (8080) - Single entry point, JWT validation
- User Service (8081) - Authentication, profiles, credits, FCM tokens
- Skill Service (8082) - Skill CRUD, geolocation search
- Mission Service (8083) - Mission lifecycle, OTP validation (Redis)
- Notification Service (8084) - FCM push notifications, Kafka consumer

**Infrastructure:**
- MongoDB Atlas (Cloud) - Data persistence (User, Skill, Mission services)
- Redis (Docker) - OTP temporary storage (Mission service)
- Kafka (Docker) - Event streaming
- Firestore - Chat messages and notification history (Mobile app)
- Firebase - Authentication & push notifications

## Quick Start

### 1. Start Docker Services
```cmd
cd skillswap-backend
docker-compose up -d
```

### 2. Configure MongoDB Atlas
1. Create free cluster at https://cloud.mongodb.com
2. Create database user
3. Whitelist IP: 0.0.0.0/0
4. Update connection strings in each service's `application.yml`

### 3. Start Services
Open 5 terminals and run:
```cmd
cd skillswap-api-gateway && mvnw spring-boot:run
cd skillswap-service-user && mvnw spring-boot:run
cd skillswap-service-skill && mvnw spring-boot:run
cd skillswap-service-mission && mvnw spring-boot:run
cd skillswap-service-notification && mvnw spring-boot:run
```

## Complete User Scenarios

### S1 - Registration (Email + Phone + OTP)
**Actor:** Guest  
**Flow:**
1. User enters: name, email, phone, password
2. System sends OTP via SMS
3. User enters OTP
4. System validates OTP
5. Account created with 20 credits bonus
6. Notification sent: "Welcome, 20 credits added"

**Rules:**
- No credits without OTP validation
- Phone number must be unique
- One bonus per phone number

### S2 - Login
**Actor:** Verified User  
**Flow:**
1. User enters email + password
2. System validates credentials
3. JWT token generated
4. User accesses dashboard

### S3 - Publish a Skill
**Actor:** Provider (Prestataire)  
**Flow:**
1. User opens "Publish Skill"
2. Fills: title, description, category, availability
3. App requests GPS permission
4. System captures coordinates
5. Skill saved in database
6. SKILL_CREATED event published to Kafka

**Result:** Skill visible in search

### S4 - Geolocation Search
**Actor:** Requester (Demandeur)  
**Flow:**
1. User opens "Find Service"
2. App detects or requests position
3. System executes geospatial query (radius = 15km)
4. Skills sorted by:
   - Helper Score (reputation)
   - Distance
5. App displays:
   - Map with approximate points
   - Detailed list

**Important:** Exact provider location never displayed

### S5 - View Provider Profile
**Actor:** Requester  
**Flow:**
1. User clicks on provider
2. System displays:
   - Avatar
   - Name
   - Skills
   - Helper Score
   - Completed missions

**Result:** Requester can decide to chat

### S6 - Chat Discussion
**Actor:** Requester and Provider  
**Flow:**
1. User opens chat
2. Firestore thread created if doesn't exist
3. Messages sent in real-time
4. For each message:
   - Kafka publishes: NEW_MESSAGE
   - Notification service sends push to recipient

### S7 - Choose Meeting Place
**Actor:** Requester and Provider  

**Option A: Partner Place**
1. User opens partner places list
2. Selects café / workspace
3. Place becomes meetingPoint.partnerPlaceId

**Option B: Map Picker**
1. User opens map
2. Places marker on public location
3. Coordinates saved as meetingPoint

### S8 - Mission Booking
**Actor:** Requester  
**Precondition:** Balance >= 5 credits  
**Flow:**
1. User clicks "Book this skill"
2. Mission service creates mission:
   - status = PENDING
   - requesterId
   - providerId
   - meetingPoint
3. Kafka publishes: MISSION_REQUESTED
4. Notification service sends push to provider

**Result:** Mission in PENDING state

### S9 - Accept or Reject Mission
**Actor:** Provider  
**Flow:**
1. Provider receives notification
2. Opens "Missions" page
3. Clicks "Accept":
   - mission.status = ACCEPTED
   - Kafka: MISSION_ACCEPTED
   - Notification → requester

**Alternative: Reject**
- mission.status = REJECTED
- Credits refunded to requester

### S10 - Meeting and Navigation
**Actor:** Requester and Provider  
**Flow:**
1. On scheduled day, user opens mission
2. Clicks "Go There"
3. App opens Google Maps/Waze to meetingPoint

### S11 - OTP Mission Validation
**Actor:** Provider and Requester  
**Flow:**
1. Provider clicks: "Generate OTP"
2. Mission service generates 6-digit code
3. Code stored in Redis (5 min expiration)
4. Kafka publishes: OTP_GENERATED
5. Provider shows code to requester
6. Requester enters OTP
7. System verifies:
   - OTP correct
   - mission.status = IN_PROGRESS
8. mission.status = COMPLETED

**Rule:** No credit transfer without correct OTP

### S12 - Credit Transfer and Helper Score
**Actor:** System  
**Flow:**
1. Debit requester account: -5 credits
2. Credit provider account: +5 credits
3. Create Ledger entry
4. Increase Helper Score
5. Kafka publishes: MISSION_COMPLETED
6. Notification service sends push to both

**Final Result:** Mission completed, credits transferred, history updated

## Mission Status Flow

```
PENDING → ACCEPTED → IN_PROGRESS → COMPLETED
   ↓          ↓            ↓
REJECTED  CANCELLED    CANCELLED
```

## API Endpoints

### Authentication (Public)
```
POST /api/auth/register - Register new user
POST /api/auth/login - Login with Firebase
```

### Users (Protected)
```
GET    /api/users/{id} - Get user profile
PUT    /api/users/{id} - Update profile
POST   /api/users/{id}/credits/debit - Debit credits
POST   /api/users/{id}/credits/credit - Credit credits
```

### Skills (Protected)
```
POST   /api/skills - Create skill
GET    /api/skills/{id} - Get skill
GET    /api/skills/near?lat&lng&r&category - Search nearby
GET    /api/skills/user/{userId} - Get user's skills
PUT    /api/skills/{id} - Update skill
DELETE /api/skills/{id} - Delete skill
```

### Missions (Protected)
```
POST   /api/missions - Create mission
GET    /api/missions/{id} - Get mission
GET    /api/missions/user/{userId}?role&status - Get user missions
POST   /api/missions/{id}/accept - Accept mission
POST   /api/missions/{id}/reject - Reject mission
POST   /api/missions/{id}/cancel - Cancel mission
POST   /api/missions/{id}/start - Start mission
POST   /api/missions/{id}/generate-otp - Generate OTP
POST   /api/missions/{id}/validate-otp - Validate OTP
```

### Notifications (Protected)
**Note**: Notification Service only sends FCM push notifications via Kafka events.
Notification history is stored in Firestore by the mobile app, not in the backend.

No REST endpoints available - notifications are triggered by Kafka events only.

## Security

### Authentication Flow
1. User registers/logs in via Firebase
2. Mobile app gets Firebase ID token
3. App calls /api/auth/login with Firebase token
4. User Service validates and generates JWT
5. App stores JWT
6. App includes JWT in all requests
7. API Gateway validates JWT
8. Gateway extracts userId and adds X-User-Id header
9. Microservices trust X-User-Id header

### Authorization Rules
- Create Mission: Any authenticated user with credits
- Accept/Reject Mission: Only skill owner (provider)
- Cancel Mission: Requester or provider
- Generate OTP: Only provider
- Validate OTP: Only requester
- Update/Delete Skill: Only skill owner

## Data Models

### User
```java
{
  userId: UUID
  firebaseUid: String
  email: String
  phoneNumber: String
  fullName: String
  phoneVerified: Boolean
  credits: Integer
  helperScore: Float
  avatar: String
  roles: [String]
  createdAt: Date
  updatedAt: Date
}
```

### Skill
```java
{
  skillId: UUID
  ownerId: UUID
  category: String
  title: String
  description: String
  geoPoint: GeoJsonPoint [lng, lat]
  active: Boolean
  createdAt: Date
  updatedAt: Date
}
```

### Mission
```java
{
  missionId: UUID
  skillId: UUID
  requesterId: UUID
  providerId: UUID
  title: String
  description: String
  status: MissionStatus
  scheduledDate: Date
  duration: Integer
  creditCost: Integer
  meetingPoint: {
    lat: Double
    lng: Double
    partnerPlaceId: UUID
  }
  generatedOtp: String
  otpExpiresAt: Date
  createdAt: Date
  updatedAt: Date
  acceptedAt: Date
  startedAt: Date
  completedAt: Date
}
```

### Notification
```java
{
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

## Kafka Events

**Topic:** mission-events

**Event Types:**
- MISSION_CREATED - New mission requested
- MISSION_ACCEPTED - Provider accepted
- MISSION_REJECTED - Provider rejected
- MISSION_STARTED - Mission in progress
- MISSION_COMPLETED - Mission finished, credits transferred
- MISSION_CANCELLED - Mission cancelled

**Event Structure:**
```json
{
  "missionId": "uuid",
  "skillId": "uuid",
  "requesterId": "uuid",
  "providerId": "uuid",
  "eventType": "MISSION_COMPLETED",
  "missionTitle": "Guitar Lessons",
  "creditAmount": 10,
  "timestamp": "2026-01-24T20:00:00Z"
}
```

## Configuration

### MongoDB Atlas
Each service needs its own database:
- skillswap-users (User Service)
- skillswap-skills (Skill Service)
- skillswap-missions (Mission Service)

**Note**: Notification Service does NOT use MongoDB. Notifications are:
- Sent via FCM (Firebase Cloud Messaging)
- Stored in Firestore by mobile app for history

Connection string format:
```
mongodb+srv://username:password@cluster.xxxxx.mongodb.net/database?retryWrites=true&w=majority
```

### Redis
```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
```

### Kafka
```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
```

### Firebase
Place `firebase-service-account.json` in:
- `skillswap-service-user/src/main/resources/`
- `skillswap-service-notification/src/main/resources/`

## Troubleshooting

### MongoDB Connection Issues
- Verify connection string
- Check IP whitelist (0.0.0.0/0)
- Verify username/password
- Check internet connection

### Kafka Not Available
- Wait 30 seconds for Kafka to start
- Check Docker: `docker-compose ps`
- View logs: `docker-compose logs kafka`

### Redis Connection Refused
- Check Docker: `docker-compose ps redis`
- Test: `docker exec skillswap-redis redis-cli ping`

### Skills Not Saving (Index Error)
1. Go to MongoDB Atlas
2. Browse Collections → skillswap-skills → skills
3. Delete all documents
4. Go to Indexes tab
5. Drop "geoPoint" index
6. Restart Skill Service

## Monitoring

### Health Checks
```
http://localhost:8080/actuator/health (API Gateway)
http://localhost:8081/actuator/health (User Service)
http://localhost:8082/actuator/health (Skill Service)
http://localhost:8083/actuator/health (Mission Service)
http://localhost:8084/actuator/health (Notification Service)
```

### Docker Services
```cmd
docker-compose ps
docker-compose logs -f
docker exec skillswap-redis redis-cli ping
docker exec skillswap-kafka kafka-topics --list --bootstrap-server localhost:9092
```

## Development

### Project Structure
```
skillswap-backend/
├── docker-compose.yml
├── skillswap-api-gateway/
├── skillswap-service-user/
├── skillswap-service-skill/
├── skillswap-service-mission/
├── skillswap-service-notification/
└── skillswap-common/
```

### Adding New Features
1. Update model in appropriate service
2. Add repository methods
3. Implement service logic
4. Create controller endpoints
5. Update API Gateway routes
6. Publish Kafka events if needed
7. Update mobile app

## Production Deployment

### Environment Variables
- MongoDB connection strings
- Redis host/port
- Kafka bootstrap servers
- Firebase credentials path
- JWT secret key

### Security Checklist
- [ ] Change JWT secret key
- [ ] Use environment variables for secrets
- [ ] Enable Kafka authentication
- [ ] Use Redis password
- [ ] Configure proper MongoDB users per service
- [ ] Enable HTTPS
- [ ] Configure CORS properly
- [ ] Set up rate limiting

### Scaling
- Each microservice can scale independently
- Use load balancer for API Gateway
- Kafka partitions for parallel processing
- MongoDB sharding for large datasets
- Redis cluster for high availability

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Verify all services are running
3. Check MongoDB Atlas connection
4. Test Docker services individually
5. Review this documentation

---

**Version:** 1.0.0  
**Last Updated:** January 2026  
**Status:** Production Ready
