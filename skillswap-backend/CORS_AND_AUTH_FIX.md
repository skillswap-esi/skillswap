# CORS and Authentication Fixes

## Issues Fixed

### 1. ✅ CORS Duplicate Headers Issue

**Problem:**
```
Access-Control-Allow-Origin header contains multiple values 
'http://localhost:63689, http://localhost:63689', but only one is allowed
```

**Root Cause:**
- Both API Gateway and User Service had CORS configurations
- This caused duplicate CORS headers in responses
- Browsers reject responses with duplicate CORS headers

**Solution:**
- Removed `CorsConfig.java` from User Service
- Kept CORS configuration only in API Gateway (single point of entry)
- API Gateway now handles all CORS for all microservices

**Files Changed:**
- ❌ Deleted: `skillswap-service-user/src/main/java/com/skillswap/user/config/CorsConfig.java`
- ✅ Kept: `skillswap-api-gateway/src/main/java/com/skillswap/gateway/config/CorsConfig.java`

### 2. ✅ 401 Unauthorized for Skills Endpoints

**Problem:**
```
Failed to load resource: the server responded with a status of 401 (Unauthorized)
GET /api/skills/near?lat=33.99&lng=-6.86&radius=10
```

**Root Cause:**
- Skills endpoints were not in the public paths list
- JWT filter was requiring authentication for all skill endpoints
- Users couldn't browse skills without logging in first

**Solution:**
- Added skill endpoints to public paths in JWT filter
- Implemented optional authentication for public paths
- Users can now browse skills without authentication
- Authenticated users still get X-User-Id header for personalized features

**Files Changed:**
- ✅ Updated: `skillswap-api-gateway/src/main/java/com/skillswap/gateway/filter/JwtAuthenticationFilter.java`

## Changes Made

### API Gateway - JWT Filter

**Public Paths Added:**
```java
private static final List<String> PUBLIC_PATHS = List.of(
    "/auth/register",
    "/auth/login",
    "/auth/firebase-login",
    "/skills/near",           // Browse nearby skills (no auth required)
    "/skills/user/",          // View user's skills (no auth required)
    "/skills/"                // View skill details (no auth required)
);
```

**Optional Authentication:**
- Public paths now support optional authentication
- If a valid token is present, X-User-Id header is added
- If no token or invalid token, request proceeds without authentication
- This allows both authenticated and unauthenticated access

### Skill Endpoints Access Control

| Endpoint | Method | Authentication | Notes |
|----------|--------|----------------|-------|
| `/api/skills/near` | GET | Optional | Browse nearby skills |
| `/api/skills/user/{userId}` | GET | Optional | View user's skills |
| `/api/skills/{skillId}` | GET | Optional | View skill details |
| `/api/skills` | POST | Required | Create skill (needs X-User-Id) |
| `/api/skills/{skillId}` | PUT | Required | Update skill (owner only) |
| `/api/skills/{skillId}` | DELETE | Required | Delete skill (owner only) |

## Testing

### Test CORS Fix

1. **Start services:**
```bash
cd skillswap-backend
start-all-services.bat
```

2. **Test from browser console:**
```javascript
fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'test@test.com', idToken: 'test' })
})
.then(r => r.json())
.then(console.log)
.catch(console.error);
```

**Expected:** No CORS errors (may get 401 for invalid token, but no CORS error)

### Test Skills Public Access

1. **Browse nearby skills (no auth):**
```bash
curl "http://localhost:8080/api/skills/near?lat=48.8566&lng=2.3522&radius=10"
```

**Expected:** 200 OK with skills list (or empty array)

2. **View user's skills (no auth):**
```bash
curl "http://localhost:8080/api/skills/user/some-user-id"
```

**Expected:** 200 OK with skills list

3. **Create skill (requires auth):**
```bash
curl -X POST http://localhost:8080/api/skills \
  -H "Content-Type: application/json" \
  -H "X-User-Id: test-user-id" \
  -d '{
    "title": "Test Skill",
    "description": "Test",
    "category": "INFORMATIQUE",
    "latitude": 48.8566,
    "longitude": 2.3522
  }'
```

**Expected:** 401 Unauthorized (needs valid JWT token)

## Mobile App Impact

### Before Fix
- ❌ CORS errors on all API calls
- ❌ Cannot browse skills without login
- ❌ Login fails due to CORS

### After Fix
- ✅ No CORS errors
- ✅ Can browse skills without login
- ✅ Login works correctly
- ✅ Authenticated users get personalized features
- ✅ Creating/updating skills requires authentication

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile App                            │
│              (Authenticated or Anonymous)                │
└─────────────────────┬───────────────────────────────────┘
                      │
                      │ HTTP Request
                      │
┌─────────────────────▼───────────────────────────────────┐
│                  API Gateway                             │
│                  (Port 8080)                             │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │         CORS Configuration                      │    │
│  │  • Single point of CORS handling                │    │
│  │  • Allows localhost with any port               │    │
│  │  • Prevents duplicate headers                   │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │      JWT Authentication Filter                  │    │
│  │  • Public paths: no auth required               │    │
│  │  • Protected paths: JWT required                │    │
│  │  • Optional auth: adds X-User-Id if present     │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼────────┐         ┌────────▼────────┐
│  User Service  │         │  Skill Service  │
│  (Port 8081)   │         │  (Port 8082)    │
│                │         │                 │
│  ❌ No CORS    │         │  ❌ No CORS     │
│  (Removed)     │         │  (Never had)    │
└────────────────┘         └─────────────────┘
```

## Security Considerations

### Public Access is Safe Because:

1. **Read-Only Operations**
   - Browsing skills doesn't expose sensitive data
   - Viewing public profiles is intended behavior
   - No personal information in skill listings

2. **Write Operations Protected**
   - Creating skills requires authentication
   - Updating skills requires owner verification
   - Deleting skills requires owner verification

3. **Optional Authentication Benefits**
   - Authenticated users get personalized results
   - X-User-Id header enables owner-specific features
   - Seamless experience for logged-in users

4. **Rate Limiting** (Future Enhancement)
   - Can add rate limiting for public endpoints
   - Prevent abuse of public APIs
   - Monitor usage patterns

## Deployment Checklist

Before deploying to production:

- [ ] Rebuild API Gateway: `mvn clean install`
- [ ] Rebuild User Service: `mvn clean install`
- [ ] Restart API Gateway
- [ ] Restart User Service
- [ ] Test CORS from production domain
- [ ] Test public skill browsing
- [ ] Test authenticated skill creation
- [ ] Monitor logs for errors
- [ ] Add rate limiting for public endpoints
- [ ] Configure production CORS origins

## Rebuild Commands

```bash
# Navigate to backend directory
cd skillswap-backend

# Rebuild API Gateway
cd skillswap-api-gateway
mvn clean install
cd ..

# Rebuild User Service
cd skillswap-service-user
mvn clean install
cd ..

# Restart all services
start-all-services.bat
```

## Verification

After restarting services, verify:

1. **CORS Headers:**
```bash
curl -I -X OPTIONS http://localhost:8080/api/auth/login \
  -H "Origin: http://localhost:63689" \
  -H "Access-Control-Request-Method: POST"
```

**Expected:** Single `Access-Control-Allow-Origin` header

2. **Public Skills Access:**
```bash
curl http://localhost:8080/api/skills/near?lat=48.8566&lng=2.3522&radius=10
```

**Expected:** 200 OK (not 401)

3. **Protected Endpoint:**
```bash
curl -X POST http://localhost:8080/api/skills \
  -H "Content-Type: application/json" \
  -d '{"title":"Test"}'
```

**Expected:** 401 Unauthorized

## Summary

✅ **CORS Issue:** Fixed by removing duplicate CORS configuration  
✅ **Auth Issue:** Fixed by adding public paths for skill browsing  
✅ **Mobile App:** Can now browse skills without authentication  
✅ **Security:** Write operations still require authentication  
✅ **User Experience:** Seamless browsing, login only when needed  

---

**Fixed:** January 23, 2026  
**Status:** ✅ Ready for Testing  
**Next:** Rebuild and restart services
