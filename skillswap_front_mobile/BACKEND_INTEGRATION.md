# Backend Integration Guide

## Overview

This document explains how the SkillSwap mobile application connects to the backend user service with Firebase authentication handled on the backend side.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Mobile App (Flutter)                      │
├─────────────────────────────────────────────────────────────────┤
│  1. User registers/logs in with Firebase Client SDK             │
│  2. Firebase returns ID Token (JWT)                             │
│  3. App sends ID Token to backend                               │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Backend (Spring Boot)                         │
├─────────────────────────────────────────────────────────────────┤
│  4. Backend verifies ID Token using Firebase Admin SDK          │
│  5. Backend creates/retrieves user profile                      │
│  6. Backend returns UserDto with full profile                   │
└─────────────────────────────────────────────────────────────────┘
```

## Why Backend Token Verification?

1. **Security**: The Firebase Admin SDK on the backend can securely verify tokens without exposing secrets
2. **Centralized User Management**: All user data is stored in MongoDB on the backend
3. **Microservices Ready**: Other services can trust the backend authentication
4. **Extended User Data**: Backend stores additional data like credits, helper scores, etc.

## Files Structure

### Mobile App (`skillswap_front_mobile/lib/`)

```
lib/
├── auth_service.dart          # Main auth service (Firebase + Backend sync)
├── core/
│   └── api_config.dart        # API URLs and endpoints configuration
├── models/
│   └── user_model.dart        # User data models
├── providers/
│   └── user_provider.dart     # User state management
├── services/
│   └── api_service.dart       # HTTP client for backend communication
└── pages/
    ├── register_page.dart     # Updated to use backend registration
    └── home_page.dart         # Shows user data from backend
```

### Backend (`skillswap-backend/skillswap-service-user/`)

```
src/main/java/com/skillswap/user/
├── services/
│   ├── FirebaseAuthService.java  # Firebase Admin SDK token verification
│   └── UserService.java          # User business logic
├── controllers/
│   └── UserController.java       # REST API endpoints
└── dto/
    ├── CreateProfileRequest.java # Requires idToken field
    └── UserDto.java              # User response format
```

## Authentication Flow

### Registration Flow

1. **Mobile**: User fills registration form (name, email, password)
2. **Mobile**: `AuthService.register()` is called
3. **Mobile**: Firebase Client SDK creates account → returns `UserCredential`
4. **Mobile**: Gets Firebase ID token via `user.getIdToken()`
5. **Mobile**: Calls `POST /users/profile` with `{email, fullName, idToken}`
6. **Backend**: `FirebaseAuthService.verifyIdToken()` validates the token
7. **Backend**: Creates user in MongoDB with initial data
8. **Backend**: Returns `UserDto` with `userId`, `creditsBalance`, etc.
9. **Mobile**: Stores user profile locally via `AuthService.userProfile`

### Login Flow

1. **Mobile**: User enters email and password
2. **Mobile**: `AuthService.signIn()` is called
3. **Mobile**: Firebase Client SDK signs in → returns `UserCredential`
4. **Mobile**: `_syncUserWithBackend()` is called automatically
5. **Mobile**: Gets user profile via `GET /users/email/{email}`
6. **Backend**: Returns existing `UserDto`
7. **Mobile**: Stores user profile locally

## API Endpoints Used

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/profile` | Create new user profile (requires `idToken`) |
| GET | `/users/me?userId={id}` | Get current user's profile |
| GET | `/users/{userId}` | Get user by ID |
| GET | `/users/email/{email}` | Get user by email |
| PUT | `/users/me?userId={id}` | Update user profile |
| POST | `/users/{userId}/verify-phone` | Verify phone & get bonus credits |
| POST | `/users/fcm-tokens?userId={id}` | Save FCM push token |
| GET | `/users/ledger?userId={id}` | Get credit transactions |

## Configuration

### Mobile App (`api_config.dart`)

```dart
// For Android Emulator
static const String _devBaseUrl = 'http://10.0.2.2:8080';

// For iOS Simulator
static const String _iosDevBaseUrl = 'http://localhost:8080';

// Direct service URL (bypassing API Gateway)
static const String userServiceUrl = 'http://10.0.2.2:8081';
```

### Backend (`application.yml`)

Ensure Firebase credentials are configured:
```yaml
firebase:
  credentials-path: classpath:firebase-service-account.json
```

## Data Models

### CreateProfileRequest (sent to backend)

```json
{
  "email": "user@example.com",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "idToken": "eyJhbGciOiJSUzI1NiIs..."
}
```

### UserDto (received from backend)

```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "fullName": "John Doe",
  "phoneVerified": false,
  "creditsBalance": 0,
  "helperScore": 0.0,
  "avatar": null,
  "roles": ["USER"],
  "fcmTokens": [],
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

## Error Handling

The `ApiService` includes comprehensive error handling:

- **Network errors**: Caught and converted to user-friendly messages
- **HTTP 4xx errors**: Client-side errors (validation, not found, etc.)
- **HTTP 5xx errors**: Server-side errors
- **Firebase errors**: Handled in auth_service with specific error codes

## Testing

### Test Registration

1. Start backend services (MongoDB, User Service)
2. Run the mobile app
3. Go to Register page
4. Enter name, email, password
5. Submit → should create both Firebase and backend accounts

### Test Login

1. Start backend services
2. Run the mobile app
3. Login with existing credentials
4. Check that user data (name, credits) appears in the UI

### Verify Backend Profile

```bash
curl http://localhost:8081/users/email/user@example.com
```

## Troubleshooting

### "Could not connect to server"
- Check if backend is running on correct port
- Check API URL configuration for your platform (emulator vs device)
- Verify network permissions in Android manifest

### "Invalid Firebase ID token"
- Token may have expired (tokens expire after 1 hour)
- Force refresh token with `getIdToken(forceRefresh: true)`
- Verify Firebase credentials on backend

### User data not showing
- Check `authService.value.userProfile` is not null
- Verify backend returned user data
- Check console for API errors

## Future Improvements

1. **Token Refresh**: Implement automatic token refresh mechanism
2. **Offline Support**: Cache user profile locally
3. **JWT Authentication**: Use backend-generated JWT for subsequent API calls
4. **Provider Integration**: Use Riverpod/Provider for better state management
