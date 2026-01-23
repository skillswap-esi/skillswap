# 🔗 Frontend-Backend Integration Guide

## Architecture Overview

```
Flutter Mobile App (Android/iOS)
         ↓
    API Gateway (Port 8080) ← Single Entry Point
         ↓
    ┌────┴────┐
    ↓         ↓
User Service  Skill Service
(Port 8081)   (Port 8082)
```

## ✅ Configuration Complete

### Backend (API Gateway)
- **Port**: 8080
- **CORS**: Enabled for all origins
- **Routes**: 
  - `/api/auth/**` → User Service (public)
  - `/api/users/**` → User Service (protected)
  - `/api/skills/**` → Skill Service (protected)
- **JWT**: Validates tokens and adds `X-User-Id` header

### Frontend (Flutter)
- **Base URL**: `http://10.0.2.2:8080` (Android Emulator)
- **Base URL**: `http://localhost:8080` (iOS Simulator)
- **All requests**: Go through API Gateway at `/api/*`

## 🚀 Testing the Integration

### Step 1: Start All Backend Services

#### Terminal 1: User Service
```bash
cd skillswap-backend/skillswap-service-user
mvn spring-boot:run
```
Wait for: `Started UserServiceApplication`

#### Terminal 2: Skill Service
```bash
cd skillswap-backend/skillswap-service-skill
mvn spring-boot:run
```
Wait for: `Started SkillServiceApplication`

#### Terminal 3: API Gateway
```bash
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```
Wait for: `Started ApiGatewayApplication`

### Step 2: Verify Backend is Ready

```bash
# Check API Gateway
curl http://localhost:8080/actuator/health

# Check User Service (direct)
curl http://localhost:8081/actuator/health

# Check Skill Service (direct)
curl http://localhost:8082/actuator/health
```

All should return: `{"status":"UP"}`

### Step 3: Test API Gateway Routing

#### Test User Service through Gateway
```bash
# This should route to User Service
curl http://localhost:8080/api/users/health
```

#### Test Skill Service through Gateway
```bash
# This should route to Skill Service
curl http://localhost:8080/api/skills/health
```

### Step 4: Start Flutter App

```bash
cd skillswap_front_mobile
flutter run
```

## 📱 Mobile App Configuration

The mobile app is already configured to use the API Gateway:

**File**: `lib/core/api_config.dart`
```dart
class ApiConfig {
  // API Gateway is the single entry point
  static const String _devBaseUrl = 'http://10.0.2.2:8080'; // Android
  static const String _iosDevBaseUrl = 'http://localhost:8080'; // iOS
  
  // All services go through API Gateway
  static String get userServiceUrl => '$apiGatewayUrl/api';
  static String get skillServiceUrl => '$apiGatewayUrl/api';
}
```

## 🔐 Authentication Flow

### 1. User Registration (Mobile → Gateway → User Service)

```
Mobile App
  ↓ POST /api/auth/register
  ↓ Body: {email, password, fullName, phoneNumber}
API Gateway (8080)
  ↓ Routes to /auth/register
User Service (8081)
  ↓ Creates user in MongoDB
  ↓ Returns JWT token
API Gateway
  ↓ Forwards response
Mobile App
  ↓ Stores JWT token
```

### 2. Create Skill (Mobile → Gateway → Skill Service)

```
Mobile App
  ↓ POST /api/skills
  ↓ Header: Authorization: Bearer JWT_TOKEN
  ↓ Body: {title, description, category, latitude, longitude}
API Gateway (8080)
  ↓ Validates JWT token
  ↓ Extracts userId from token
  ↓ Adds X-User-Id header
  ↓ Routes to /skills
Skill Service (8082)
  ↓ Receives X-User-Id header
  ↓ Creates skill in MongoDB
  ↓ Returns skill data
API Gateway
  ↓ Forwards response
Mobile App
  ↓ Displays skill
```

## 🧪 Testing from Mobile App

### Test 1: Register a User

1. Open the mobile app
2. Go to Register screen
3. Fill in:
   - Email: `test@example.com`
   - Password: `Test123!`
   - Full Name: `Test User`
   - Phone: `+33612345678`
4. Click Register

**Expected**: 
- User created in MongoDB (`skillswap-users` database)
- JWT token received
- Redirected to home screen

**Backend Logs to Check**:
```
API Gateway: POST /api/auth/register
User Service: Creating user with email: test@example.com
User Service: User created successfully
```

### Test 2: Login

1. Go to Login screen
2. Enter email and password
3. Click Login

**Expected**:
- JWT token received
- User profile loaded
- Redirected to home screen

### Test 3: Create a Skill

1. After login, go to Create Skill screen
2. Fill in:
   - Title: `Cours de guitare`
   - Description: `Cours pour débutants`
   - Category: `MUSIQUE`
   - Location: Use current location or enter manually
3. Click Create

**Expected**:
- Skill created in MongoDB (`skillswap-skills` database)
- Skill appears in list
- Geospatial index created automatically

**Backend Logs to Check**:
```
API Gateway: POST /api/skills
API Gateway: JWT validated, userId extracted
Skill Service: Creating skill for owner: {userId}
Skill Service: Skill created successfully
```

### Test 4: Search Skills Near Location

1. Go to Search screen
2. Enter location or use current
3. Set radius (e.g., 10 km)
4. Click Search

**Expected**:
- Skills within radius returned
- Sorted by distance
- Distance displayed for each skill

## 🔍 Debugging

### Check API Gateway Logs

Look for:
```
Processing request: /api/auth/register
Public path, skipping authentication
Routing to: http://localhost:8081/auth/register
```

Or for protected routes:
```
Processing request: /api/skills
Authenticated user: {userId}
Adding X-User-Id header
Routing to: http://localhost:8082/skills
```

### Check Service Logs

**User Service**:
```
POST /auth/register - Creating user
User created with ID: {userId}
Generating JWT token
```

**Skill Service**:
```
POST /skills - Creating skill for user: {userId}
Skill created successfully with ID: {skillId}
```

### Common Issues

#### Issue: "Connection refused" from mobile app

**Solution**: 
- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For iOS Simulator, use `localhost` or `127.0.0.1`
- For physical device, use your computer's IP address (e.g., `192.168.1.100`)

#### Issue: "Unauthorized" error

**Solution**:
- Check JWT token is being sent in `Authorization: Bearer TOKEN` header
- Verify token hasn't expired (24h validity)
- Check API Gateway logs for JWT validation errors

#### Issue: CORS error in browser (if testing web version)

**Solution**: Already configured in API Gateway:
```yaml
globalcors:
  corsConfigurations:
    '[/**]':
      allowedOrigins: "*"
      allowedMethods: [GET, POST, PUT, DELETE, OPTIONS]
      allowedHeaders: "*"
```

## 📊 Request Flow Examples

### Example 1: Complete Registration Flow

```bash
# 1. Mobile app sends registration request
POST http://10.0.2.2:8080/api/auth/register
Content-Type: application/json

{
  "email": "john@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "John Doe"
}

# 2. API Gateway routes to User Service
POST http://localhost:8081/auth/register
Content-Type: application/json

{
  "email": "john@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "John Doe"
}

# 3. User Service responds with JWT
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "john@example.com",
  "fullName": "John Doe"
}

# 4. API Gateway forwards response to mobile app
```

### Example 2: Create Skill with JWT

```bash
# 1. Mobile app sends create skill request
POST http://10.0.2.2:8080/api/skills
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "title": "Cours de guitare",
  "description": "Cours pour débutants",
  "category": "MUSIQUE",
  "latitude": 48.8566,
  "longitude": 2.3522
}

# 2. API Gateway validates JWT and extracts userId
# 3. API Gateway routes to Skill Service with X-User-Id header
POST http://localhost:8082/skills
X-User-Id: 123e4567-e89b-12d3-a456-426614174000
Content-Type: application/json

{
  "title": "Cours de guitare",
  "description": "Cours pour débutants",
  "category": "MUSIQUE",
  "latitude": 48.8566,
  "longitude": 2.3522
}

# 4. Skill Service creates skill and responds
{
  "skillId": "456e7890-e89b-12d3-a456-426614174001",
  "ownerId": "123e4567-e89b-12d3-a456-426614174000",
  "title": "Cours de guitare",
  "description": "Cours pour débutants",
  "category": "MUSIQUE",
  "latitude": 48.8566,
  "longitude": 2.3522,
  "active": true,
  "createdAt": "2026-01-22T18:00:00Z"
}

# 5. API Gateway forwards response to mobile app
```

## ✅ Integration Checklist

- [x] API Gateway configured on port 8080
- [x] User Service running on port 8081
- [x] Skill Service running on port 8082
- [x] API Gateway routes configured
- [x] JWT authentication in Gateway
- [x] CORS enabled in Gateway
- [x] Mobile app configured to use Gateway
- [x] All requests go through `/api/*`
- [ ] Test user registration from mobile
- [ ] Test login from mobile
- [ ] Test skill creation from mobile
- [ ] Test skill search from mobile
- [ ] Verify MongoDB collections created
- [ ] Verify JWT tokens work end-to-end

## 🎯 Success Criteria

✅ Mobile app can register users  
✅ Mobile app can login  
✅ Mobile app receives JWT tokens  
✅ Mobile app can create skills with JWT  
✅ Mobile app can search skills  
✅ All requests go through API Gateway  
✅ No direct service calls from mobile  
✅ MongoDB collections auto-created  
✅ Geospatial search works  

---

**Status**: ✅ READY FOR INTEGRATION TESTING  
**Date**: January 22, 2026  
**Next**: Test from mobile app
