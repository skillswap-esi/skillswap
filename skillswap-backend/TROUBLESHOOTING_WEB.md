# 🔧 Troubleshooting - Web Platform Issues

## Issue: "Failed to fetch" on Web

### Problem
```
Failed to create backend profile: ClientException: Failed to fetch,
uri=http://10.0.2.2:8080/api/auth/register
```

### Root Cause
The app is running on **web** (Chrome browser), but the API config was using `10.0.2.2` which is only for Android emulators.

### Solution ✅

The API configuration has been updated to automatically detect the platform:

**File**: `skillswap_front_mobile/lib/core/api_config.dart`

```dart
static String get baseUrl {
  if (kIsWeb) {
    // Running on web → use localhost
    return 'http://localhost:8080';
  } else if (Platform.isAndroid) {
    // Android emulator → use special IP
    return 'http://10.0.2.2:8080';
  } else {
    // iOS/macOS/Windows/Linux → use localhost
    return 'http://localhost:8080';
  }
}
```

## Verify Services Are Running

### Quick Test
```bash
# Test API Gateway
curl http://localhost:8080/actuator/health

# Test User Service
curl http://localhost:8081/actuator/health

# Test Skill Service
curl http://localhost:8082/actuator/health
```

### Or Run Test Script
```bash
cd skillswap-backend
test-services-running.bat
```

## Start Services (If Not Running)

### Terminal 1: User Service
```bash
cd skillswap-backend/skillswap-service-user
mvn spring-boot:run
```
**Wait for**: `Started UserServiceApplication`

### Terminal 2: Skill Service
```bash
cd skillswap-backend/skillswap-service-skill
mvn spring-boot:run
```
**Wait for**: `Started SkillServiceApplication`

### Terminal 3: API Gateway
```bash
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```
**Wait for**: `Started ApiGatewayApplication`

## CORS Configuration

CORS has been added to both services to allow web requests:

**Files Created**:
- `skillswap-service-user/src/main/java/com/skillswap/user/config/CorsConfig.java`
- `skillswap-service-skill/src/main/java/com/skillswap/skill/config/CorsConfig.java`

**Configuration**:
- Allows all origins in development (`*`)
- Allows credentials (cookies, auth headers)
- Allows common HTTP methods (GET, POST, PUT, DELETE)
- Exposes Authorization and X-User-Id headers

## Restart Services After CORS Changes

After adding CORS configuration, you need to restart the services:

```bash
# Stop all services (Ctrl+C in each terminal)

# Rebuild and restart User Service
cd skillswap-backend/skillswap-service-user
mvn clean spring-boot:run

# Rebuild and restart Skill Service
cd skillswap-backend/skillswap-service-skill
mvn clean spring-boot:run

# Restart API Gateway (no changes needed)
cd skillswap-backend/skillswap-api-gateway
mvn spring-boot:run
```

## Test Registration on Web

### 1. Restart Flutter App
```bash
cd skillswap_front_mobile
flutter run -d chrome
```

### 2. Open Browser Console
Press `F12` to open DevTools and check:
- **Console**: Look for errors
- **Network**: Check if requests are being sent to `http://localhost:8080`

### 3. Register a User
- Click "Register"
- Fill form:
  - Name: `Test User`
  - Email: `test@example.com`
  - Phone: `+33612345678`
  - Password: `password123`
- Submit

### 4. Check Network Tab
You should see:
```
POST http://localhost:8080/api/auth/register
Status: 201 Created
Response: { userId: "...", email: "test@example.com", ... }
```

## Common Issues

### Issue 1: Services Not Running

**Symptoms**: Connection refused, failed to fetch

**Solution**: Start all 3 services (User, Skill, API Gateway)

### Issue 2: CORS Errors

**Symptoms**: 
```
Access to fetch at 'http://localhost:8080/api/auth/register' from origin 
'http://localhost:53151' has been blocked by CORS policy
```

**Solution**: 
1. Verify CORS config files exist
2. Restart services after adding CORS
3. Check browser console for specific CORS error

### Issue 3: Wrong Port

**Symptoms**: Connection refused on port 8080

**Solution**: 
- Check if API Gateway is running on port 8080
- Check if another app is using port 8080
- Change port in `application.yml` if needed

### Issue 4: Firebase Not Initialized

**Symptoms**: "Firebase not initialized" error

**Solution**: 
- Check `firebase-service-account.json` exists in `src/main/resources/`
- Verify Firebase project configuration
- Check User Service logs for Firebase initialization

### Issue 5: MongoDB Connection Failed

**Symptoms**: "Failed to connect to MongoDB" error

**Solution**: 
- Check MongoDB Atlas connection string
- Verify network access (whitelist your IP)
- Check database user credentials

## Platform-Specific URLs

| Platform | URL | Notes |
|----------|-----|-------|
| Web (Chrome/Firefox) | `http://localhost:8080` | ✅ Auto-detected |
| Android Emulator | `http://10.0.2.2:8080` | ✅ Auto-detected |
| iOS Simulator | `http://localhost:8080` | ✅ Auto-detected |
| Physical Device | `http://YOUR_IP:8080` | ⚠️ Manual config needed |

### For Physical Devices

If testing on a physical device, update `api_config.dart`:

```dart
static const String _physicalDeviceUrl = 'http://192.168.1.100:8080'; // Your machine's IP

static String get baseUrl {
  // ... existing code ...
  
  // For physical device testing, uncomment:
  // return _physicalDeviceUrl;
}
```

Find your IP:
- **Windows**: `ipconfig` → Look for IPv4 Address
- **Mac/Linux**: `ifconfig` → Look for inet address

## Verify Everything Works

### 1. Check Services
```bash
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
```

All should return: `{"status":"UP"}`

### 2. Test Registration
```bash
# This will fail with invalid token, but proves endpoint is accessible
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","fullName":"Test","idToken":"test"}'
```

Should return: `401 Unauthorized` or `Invalid Firebase ID token` (this is expected)

### 3. Test from Flutter Web
- Open app in Chrome
- Open DevTools (F12)
- Register a user
- Check Network tab for successful request

## Success Checklist

✅ All 3 services running (User, Skill, API Gateway)
✅ CORS configuration added to services
✅ Services restarted after CORS changes
✅ API config detects web platform correctly
✅ Flutter app running on web (Chrome)
✅ Registration request goes to `http://localhost:8080`
✅ No CORS errors in browser console
✅ User created in MongoDB

## Next Steps

After successful registration:
1. Check MongoDB Atlas for new user document
2. Test login flow
3. Test creating a skill
4. Switch to Android emulator or iOS simulator for mobile testing

---

**Need Help?** Check the logs:
- User Service: Look for "POST /auth/register" and "Profile created"
- API Gateway: Look for "Route matched: user-service-auth"
- Browser Console: Look for network errors or CORS issues
