# 🔐 Firebase Auth + MongoDB Integration Guide

## Overview

SkillSwap uses a hybrid authentication system:
- **Firebase Auth**: Handles user authentication (email/password, social login)
- **MongoDB**: Stores user profiles, credits, and application data
- **API Gateway**: Verifies JWT tokens and routes requests

## Architecture Flow

```
┌─────────────┐
│   Mobile    │
│     App     │
└──────┬──────┘
       │
       │ 1. Register/Login
       ▼
┌─────────────┐
│  Firebase   │
│    Auth     │
└──────┬──────┘
       │
       │ 2. Returns JWT Token
       ▼
┌─────────────┐
│   Mobile    │
│     App     │
└──────┬──────┘
       │
       │ 3. POST /auth/register or /auth/login (with JWT)
       ▼
┌─────────────┐
│     API     │
│   Gateway   │ ← 4. Verifies JWT
└──────┬──────┘
       │
       │ 5. Routes to User Service
       ▼
┌─────────────┐
│    User     │
│   Service   │ ← 6. Creates/Retrieves MongoDB User
└──────┬──────┘
       │
       │ 7. Returns User Profile
       ▼
┌─────────────┐
│   Mobile    │
│     App     │
└─────────────┘
```

## Registration Flow

### Step 1: User Signs Up (Mobile App)

**File**: `skillswap_front_mobile/lib/pages/register_page.dart`

```dart
// User fills form:
// - Full Name
// - Email
// - Phone Number (optional)
// - Password
// - Confirm Password

await authService.value.register(
  email: email,
  password: password,
  fullName: fullName,
  phoneNumber: phoneNumber, // optional
);
```

### Step 2: Firebase Authentication (Mobile App)

**File**: `skillswap_front_mobile/lib/auth_service.dart`

```dart
// 1. Create Firebase account
final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// 2. Get Firebase ID token
final idToken = await credential.user?.getIdToken();
```

### Step 3: Register in Backend (Mobile App)

**File**: `skillswap_front_mobile/lib/services/api_service.dart`

```dart
// 3. Call backend registration endpoint
POST http://localhost:8080/api/auth/register
Headers: Content-Type: application/json
Body: {
  "email": "user@example.com",
  "fullName": "John Doe",
  "phoneNumber": "+33612345678", // optional
  "idToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Step 4: API Gateway Verification

**File**: `skillswap-backend/skillswap-api-gateway/src/main/java/com/skillswap/gateway/config/GatewayConfig.java`

```java
// Auth endpoints are PUBLIC (no JWT verification needed)
.route("user-service-auth", r -> r
    .path("/api/auth/**")
    .filters(f -> f.stripPrefix(1))
    .uri("http://localhost:8081"))
```

**Note**: Auth endpoints (`/api/auth/**`) are public because the Firebase ID token is verified by the User Service, not the API Gateway.

### Step 5: User Service Creates MongoDB Profile

**File**: `skillswap-backend/skillswap-service-user/src/main/java/com/skillswap/user/controllers/AuthController.java`

```java
@PostMapping("/register")
public ResponseEntity<UserDto> register(@Valid @RequestBody RegisterRequest request) {
    // 1. Verify Firebase ID token
    String firebaseUid = firebaseAuthService.verifyIdToken(request.getIdToken());
    
    // 2. Create MongoDB user document
    User user = new User();
    user.setUserId(UUID.randomUUID());
    user.setEmail(request.getEmail());
    user.setPhoneNumber(request.getPhoneNumber());
    user.setFullName(request.getFullName());
    user.setPhoneVerified(false);
    user.setCreditsBalance(0); // Initial balance
    user.setHelperScore(0.0f);
    user.setRoles(List.of("USER"));
    user.setCreatedAt(new Date());
    
    // 3. Save to MongoDB
    User savedUser = userRepository.save(user);
    
    // 4. Return user profile
    return ResponseEntity.status(HttpStatus.CREATED).body(userMapper.toDto(savedUser));
}
```

### Step 6: MongoDB Collection Created

**Database**: `skillswap-users`
**Collection**: `users`

```json
{
  "_id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "user@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "John Doe",
  "phoneVerified": false,
  "creditsBalance": 0,
  "helperScore": 0.0,
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": "2026-01-22T18:00:00Z",
  "updatedAt": "2026-01-22T18:00:00Z",
  "_class": "com.skillswap.user.model.User"
}
```

### Step 7: Complete Profile (Optional)

If phone number was not provided during registration, the app shows a profile completion page.

**File**: `skillswap_front_mobile/lib/pages/complete_profile_page.dart`

```dart
// User can:
// 1. Add phone number
// 2. Skip for now
// 3. Learn about phone verification bonus (50 credits)
```

## Login Flow

### Step 1: User Logs In (Mobile App)

**File**: `skillswap_front_mobile/lib/pages/login_page.dart`

```dart
await authService.value.signIn(
  email: email,
  password: password,
);
```

### Step 2: Firebase Authentication

```dart
// 1. Sign in with Firebase
final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// 2. Get Firebase ID token
final idToken = await credential.user?.getIdToken();
```

### Step 3: Login to Backend

```dart
// 3. Call backend login endpoint
POST http://localhost:8080/api/auth/login
Headers: Content-Type: application/json
Body: {
  "email": "user@example.com",
  "idToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Step 4: User Service Retrieves Profile

```java
@PostMapping("/login")
public ResponseEntity<UserDto> login(@Valid @RequestBody LoginRequest request) {
    // 1. Verify Firebase ID token
    String firebaseUid = firebaseAuthService.verifyIdToken(request.getIdToken());
    
    // 2. Get user from MongoDB
    try {
        UserDto user = userService.getUserByEmail(request.getEmail());
        return ResponseEntity.ok(user);
    } catch (UserNotFoundException e) {
        // User doesn't exist in MongoDB, create profile
        // (This handles cases where user was created in Firebase but not in MongoDB)
        UserDto user = userService.createProfile(...);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
}
```

## Phone Verification Flow

### Step 1: User Verifies Phone

**File**: `skillswap_front_mobile/lib/pages/settings_page.dart`

```dart
// User clicks "Verify Phone Number"
await authService.value.verifyPhone();
```

### Step 2: Backend Awards Bonus Credits

**File**: `skillswap-backend/skillswap-service-user/src/main/java/com/skillswap/user/services/UserService.java`

```java
@Transactional
public UserDto verifyPhone(UUID userId) {
    User user = userRepository.findById(userId).orElseThrow();
    
    if (!user.isPhoneVerified()) {
        // 1. Mark phone as verified
        user.setPhoneVerified(true);
        
        // 2. Award bonus credits
        user.setCreditsBalance(user.getCreditsBalance() + 50);
        
        // 3. Create ledger transaction
        LedgerTransaction bonus = new LedgerTransaction();
        bonus.setToUserId(userId);
        bonus.setAmount(50);
        bonus.setDescription("Phone verification bonus");
        ledgerTransactionRepository.save(bonus);
        
        // 4. TODO: Publish PHONE_VERIFIED event to Kafka
        // kafkaTemplate.send("phone-verified-events", event);
    }
    
    return userMapper.toDto(user);
}
```

## Protected Endpoints

All endpoints except `/api/auth/**` require JWT authentication.

### API Gateway JWT Verification

**File**: `skillswap-backend/skillswap-api-gateway/src/main/java/com/skillswap/gateway/filter/JwtAuthenticationFilter.java`

```java
// 1. Extract JWT from Authorization header
String token = exchange.getRequest().getHeaders().getFirst("Authorization");

// 2. Verify JWT signature
Claims claims = jwtUtil.validateToken(token);

// 3. Extract userId from JWT
String userId = claims.getSubject();

// 4. Add X-User-Id header for downstream services
ServerHttpRequest modifiedRequest = exchange.getRequest().mutate()
    .header("X-User-Id", userId)
    .build();
```

### User Service Reads X-User-Id

```java
@GetMapping("/me")
public ResponseEntity<UserDto> getCurrentUser(@RequestHeader("X-User-Id") String userId) {
    UserDto user = userService.getUserById(UUID.fromString(userId));
    return ResponseEntity.ok(user);
}
```

## Key Configuration Files

### Mobile App

1. **API Config**: `skillswap_front_mobile/lib/core/api_config.dart`
   - API Gateway URL: `http://10.0.2.2:8080` (Android) or `http://localhost:8080` (iOS)
   - Auth endpoints: `/api/auth/register`, `/api/auth/login`

2. **Auth Service**: `skillswap_front_mobile/lib/auth_service.dart`
   - Firebase Auth integration
   - Backend synchronization

3. **API Service**: `skillswap_front_mobile/lib/services/api_service.dart`
   - HTTP client for backend API calls

### Backend

1. **User Service Config**: `skillswap-backend/skillswap-service-user/src/main/resources/application.yml`
   ```yaml
   spring:
     data:
       mongodb:
         uri: mongodb+srv://...@cluster.mongodb.net/skillswap-users
         auto-index-creation: true
   
   firebase:
     credentials-path: classpath:firebase-service-account.json
   ```

2. **API Gateway Config**: `skillswap-backend/skillswap-api-gateway/src/main/resources/application.yml`
   ```yaml
   spring:
     cloud:
       gateway:
         routes:
           - id: user-service-auth
             uri: http://localhost:8081
             predicates:
               - Path=/api/auth/**
             filters:
               - StripPrefix=1
   ```

## Testing the Flow

### 1. Start Services

```bash
# Terminal 1: User Service
cd skillswap-backend/skillswap-service-user
mvn spring-boot:run

# Terminal 2: Skill Service
cd skillswap-backend/skillswap-service-skill
mvn spring-boot:run

# Terminal 3: API Gateway
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```

### 2. Test Registration with cURL

```bash
# This won't work directly because you need a real Firebase ID token
# Use the mobile app or Firebase Auth REST API to get a token

curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "fullName": "Test User",
    "phoneNumber": "+33612345678",
    "idToken": "YOUR_FIREBASE_ID_TOKEN"
  }'
```

### 3. Test with Mobile App

```bash
# Start Flutter app
cd skillswap_front_mobile
flutter run
```

1. Click "Register"
2. Fill in the form
3. Submit
4. Check MongoDB Atlas for new user document
5. Check app navigates to home or complete profile page

## Troubleshooting

### Collections Not Created

**Problem**: MongoDB collections don't exist after starting services.

**Solution**: Collections are created lazily when first document is inserted. Register a user to create the `users` collection.

### Firebase Token Verification Fails

**Problem**: "Invalid Firebase ID token" error.

**Solution**: 
1. Check `firebase-service-account.json` exists in `src/main/resources/`
2. Verify Firebase project configuration
3. Check Firebase Admin SDK initialization logs

### User Already Exists

**Problem**: "Email already exists" or "Phone number already exists" error.

**Solution**: Email and phone number must be unique. Use a different email/phone or delete the existing user from MongoDB.

### API Gateway Returns 401

**Problem**: Protected endpoints return 401 Unauthorized.

**Solution**: 
1. Ensure JWT token is included in Authorization header
2. Verify JWT secret matches between User Service and API Gateway
3. Check token hasn't expired (default: 24 hours)

## Security Notes

### JWT Secret

**Current**: `skillswap-secret-key-change-this-in-production-2024`

**⚠️ IMPORTANT**: Change this in production! Use a strong, randomly generated secret.

```yaml
# application.yml
jwt:
  secret: ${JWT_SECRET:your-production-secret-here}
  expiration: 86400000 # 24 hours
```

### Firebase Service Account

**⚠️ IMPORTANT**: Never commit `firebase-service-account.json` to version control!

Add to `.gitignore`:
```
**/firebase-service-account.json
```

### CORS Configuration

**Current**: Allows all origins (`*`)

**⚠️ IMPORTANT**: Restrict in production:

```yaml
# API Gateway application.yml
spring:
  cloud:
    gateway:
      globalcors:
        corsConfigurations:
          '[/**]':
            allowedOrigins: 
              - "https://skillswap.com"
              - "https://app.skillswap.com"
```

## Summary

✅ **Registration**: Firebase Auth → Backend creates MongoDB user with 0 credits
✅ **Login**: Firebase Auth → Backend retrieves MongoDB user
✅ **Phone Verification**: Backend awards 50 bonus credits
✅ **Protected Endpoints**: API Gateway verifies JWT, adds X-User-Id header
✅ **Collections**: Created lazily on first insert
✅ **Integration**: Mobile app ↔ API Gateway ↔ User Service ↔ MongoDB

The system is now fully integrated and ready for testing!
