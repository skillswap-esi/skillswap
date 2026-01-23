# 🧪 Test Authentication Flow

## Prerequisites

1. All services running:
   - User Service (port 8081)
   - Skill Service (port 8082)
   - API Gateway (port 8080)

2. MongoDB Atlas accessible

3. Firebase project configured

## Test Scenarios

### Scenario 1: Register New User via Mobile App

**Steps**:
1. Open mobile app
2. Click "Register"
3. Fill form:
   - Full Name: "Test User"
   - Email: "test@example.com"
   - Phone: "+33612345678" (optional)
   - Password: "password123"
   - Confirm Password: "password123"
4. Click "Create Account"

**Expected Result**:
- ✅ Firebase account created
- ✅ Backend receives Firebase ID token
- ✅ MongoDB user document created in `skillswap-users.users`
- ✅ User has `creditsBalance: 0`
- ✅ User has `phoneVerified: false`
- ✅ App navigates to home or complete profile page

**Verify in MongoDB Atlas**:
```javascript
use skillswap-users
db.users.findOne({ email: "test@example.com" })
```

Should return:
```json
{
  "_id": "...",
  "email": "test@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "Test User",
  "phoneVerified": false,
  "creditsBalance": 0,
  "helperScore": 0.0,
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": ISODate("..."),
  "updatedAt": ISODate("..."),
  "_class": "com.skillswap.user.model.User"
}
```

### Scenario 2: Register Without Phone Number

**Steps**:
1. Open mobile app
2. Click "Register"
3. Fill form (leave phone number empty)
4. Click "Create Account"

**Expected Result**:
- ✅ User created with `phoneNumber: null`
- ✅ App shows "Complete Profile" page
- ✅ User can add phone or skip

### Scenario 3: Login Existing User

**Steps**:
1. Open mobile app
2. Click "Login"
3. Enter email and password
4. Click "Login"

**Expected Result**:
- ✅ Firebase authentication succeeds
- ✅ Backend retrieves user from MongoDB
- ✅ App navigates to home page
- ✅ User profile loaded

### Scenario 4: Verify Phone Number

**Steps**:
1. Login to app
2. Go to Settings
3. Click "Verify Phone Number"
4. Complete verification (implementation pending)

**Expected Result**:
- ✅ `phoneVerified` set to `true`
- ✅ `creditsBalance` increased by 50
- ✅ Ledger transaction created
- ✅ User sees updated balance

**Verify in MongoDB**:
```javascript
db.users.findOne({ email: "test@example.com" })
// Should show: phoneVerified: true, creditsBalance: 50

db.ledgerTransactions.find({ toUserId: "..." })
// Should show transaction with description: "Phone verification bonus"
```

### Scenario 5: Create Skill (Tests JWT Flow)

**Steps**:
1. Login to app
2. Navigate to "Create Skill"
3. Fill form:
   - Title: "Guitar Lessons"
   - Description: "Beginner guitar lessons"
   - Category: "MUSIQUE"
   - Location: Paris (48.8566, 2.3522)
4. Click "Create"

**Expected Result**:
- ✅ App sends request with JWT token
- ✅ API Gateway verifies JWT
- ✅ API Gateway adds X-User-Id header
- ✅ Skill Service creates skill
- ✅ MongoDB `skillswap-skills.skills` collection created
- ✅ Skill linked to user via `ownerId`

**Verify in MongoDB**:
```javascript
use skillswap-skills
db.skills.findOne({ title: "Guitar Lessons" })
```

Should return:
```json
{
  "_id": "...",
  "ownerId": "...", // matches user's userId
  "title": "Guitar Lessons",
  "description": "Beginner guitar lessons",
  "category": "MUSIQUE",
  "geoPoint": {
    "type": "Point",
    "coordinates": [2.3522, 48.8566]
  },
  "active": true,
  "createdAt": ISODate("..."),
  "updatedAt": ISODate("..."),
  "_class": "com.skillswap.skill.model.Skill"
}
```

## Manual Testing with cURL

### Get Firebase ID Token

You need a real Firebase ID token. Options:

1. **Use Firebase Auth REST API**:
```bash
# Sign up
curl -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "returnSecureToken": true
  }'

# Response includes idToken
```

2. **Use Mobile App**: Register/login and extract token from logs

3. **Use Firebase Console**: Generate custom token

### Test Registration

```bash
# Replace YOUR_FIREBASE_ID_TOKEN with actual token
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "fullName": "Test User",
    "phoneNumber": "+33612345678",
    "idToken": "YOUR_FIREBASE_ID_TOKEN"
  }'
```

**Expected Response** (201 Created):
```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "test@example.com",
  "phoneNumber": "+33612345678",
  "fullName": "Test User",
  "phoneVerified": false,
  "creditsBalance": 0,
  "helperScore": 0.0,
  "roles": ["USER"],
  "createdAt": "2026-01-22T18:00:00Z",
  "updatedAt": "2026-01-22T18:00:00Z"
}
```

### Test Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "idToken": "YOUR_FIREBASE_ID_TOKEN"
  }'
```

**Expected Response** (200 OK):
```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "test@example.com",
  ...
}
```

### Test Protected Endpoint

```bash
# Get user profile (requires JWT)
curl -X GET "http://localhost:8080/api/users/me?userId=123e4567-e89b-12d3-a456-426614174000" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Expected Response** (200 OK):
```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "test@example.com",
  ...
}
```

## Check Service Logs

### User Service Logs

Look for:
```
✓ Firebase Admin SDK initialized successfully
POST /auth/register - email: test@example.com
✓ Token verified successfully for Firebase UID: ...
Profile created successfully for userId: ...
```

### API Gateway Logs

Look for:
```
Route matched: user-service-auth
Forwarding request to: http://localhost:8081/auth/register
```

For protected endpoints:
```
JWT token validated for user: ...
Added X-User-Id header: ...
```

### Skill Service Logs

Look for:
```
POST /skills - Creating skill for ownerId: ...
Skill created successfully: ...
```

## Common Issues

### Issue 1: "Invalid Firebase ID token"

**Cause**: Token expired or invalid

**Solution**: 
- Get a fresh token
- Check Firebase service account JSON is correct
- Verify Firebase Admin SDK initialized

### Issue 2: "Email already exists"

**Cause**: User already registered

**Solution**: 
- Use different email
- Delete user from MongoDB: `db.users.deleteOne({ email: "test@example.com" })`
- Delete from Firebase Console

### Issue 3: Collections not created

**Cause**: No data inserted yet

**Solution**: 
- Register a user (creates `users` collection)
- Create a skill (creates `skills` collection)
- Collections are created lazily

### Issue 4: 401 Unauthorized on protected endpoints

**Cause**: Missing or invalid JWT token

**Solution**: 
- Include Authorization header: `Bearer YOUR_JWT_TOKEN`
- Verify JWT secret matches in User Service and API Gateway
- Check token hasn't expired

## Success Criteria

✅ User can register via mobile app
✅ User document created in MongoDB with correct fields
✅ User can login and profile is retrieved
✅ Phone verification awards 50 credits
✅ Protected endpoints require JWT
✅ Skills can be created and linked to users
✅ Both `users` and `skills` collections exist in MongoDB

## Next Steps

After successful testing:

1. **Implement phone verification UI** in mobile app
2. **Add Kafka events** for phone verification
3. **Implement mission service** for skill exchanges
4. **Add notification service** for push notifications
5. **Implement credit transfer** for completed missions

---

**Ready to test!** Start all services and try registering a new user. 🚀
