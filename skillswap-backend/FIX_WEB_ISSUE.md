# 🔧 Quick Fix - Web Platform Issue

## Problem
```
Failed to create backend profile: ClientException: Failed to fetch,
uri=http://10.0.2.2:8080/api/auth/register
```

## Root Cause
App running on **web** (Chrome) but using Android emulator IP (`10.0.2.2`)

## ✅ Solution Applied

### 1. Updated API Config (Auto-detects Platform)
**File**: `skillswap_front_mobile/lib/core/api_config.dart`
- ✅ Web → uses `http://localhost:8080`
- ✅ Android → uses `http://10.0.2.2:8080`
- ✅ iOS → uses `http://localhost:8080`

### 2. Added CORS Configuration
**Files Created**:
- ✅ `skillswap-service-user/src/main/java/com/skillswap/user/config/CorsConfig.java`
- ✅ `skillswap-service-skill/src/main/java/com/skillswap/skill/config/CorsConfig.java`

## 🚀 What You Need to Do

### Step 1: Restart Backend Services

**Stop all services** (Ctrl+C in each terminal), then:

#### Terminal 1: User Service
```bash
cd skillswap-backend/skillswap-service-user
mvn clean spring-boot:run
```
Wait for: `Started UserServiceApplication`

#### Terminal 2: Skill Service
```bash
cd skillswap-backend/skillswap-service-skill
mvn clean spring-boot:run
```
Wait for: `Started SkillServiceApplication`

#### Terminal 3: API Gateway
```bash
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```
Wait for: `Started ApiGatewayApplication`

### Step 2: Restart Flutter App

```bash
cd skillswap_front_mobile

# Stop current app (Ctrl+C)

# Restart on web
flutter run -d chrome
```

### Step 3: Test Registration

1. Open app in Chrome
2. Press `F12` to open DevTools
3. Go to **Network** tab
4. Click "Register"
5. Fill form and submit
6. Check Network tab for request to `http://localhost:8080/api/auth/register`

## ✅ Expected Result

### Network Tab Should Show:
```
POST http://localhost:8080/api/auth/register
Status: 201 Created
Response: {
  "userId": "...",
  "email": "test@example.com",
  "fullName": "Test User",
  "phoneNumber": "+33612345678",
  "phoneVerified": false,
  "creditsBalance": 0,
  ...
}
```

### User Service Logs Should Show:
```
POST /auth/register - email: test@example.com
✓ Token verified successfully for Firebase UID: ...
Profile created successfully for userId: ...
```

### MongoDB Should Have:
```javascript
use skillswap-users
db.users.findOne({ email: "test@example.com" })
// Should return the user document
```

## 🐛 If Still Not Working

### Check Services Are Running
```bash
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
```

All should return: `{"status":"UP"}`

### Check Browser Console
Press `F12` → Console tab
Look for:
- ❌ CORS errors
- ❌ Connection refused
- ❌ Network errors

### Check Service Logs
Look for:
- User Service: Firebase initialization
- API Gateway: Route configuration
- Any error messages

## 📝 Summary

**Changes Made**:
1. ✅ API config now auto-detects platform (web/Android/iOS)
2. ✅ CORS configuration added to both services
3. ✅ Web now uses `localhost:8080` instead of `10.0.2.2:8080`

**What You Need to Do**:
1. 🔄 Restart all 3 backend services (with `mvn clean`)
2. 🔄 Restart Flutter app
3. ✅ Test registration

**After This**:
- Registration should work on web
- Login should work on web
- Can test on Android emulator (will use `10.0.2.2:8080` automatically)
- Can test on iOS simulator (will use `localhost:8080` automatically)

---

**Ready to test!** Restart the services and try again. 🚀
