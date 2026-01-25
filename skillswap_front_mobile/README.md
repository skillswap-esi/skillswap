# SkillSwap Mobile App - Complete Documentation

## Overview

Flutter mobile application for SkillSwap platform - skill exchange with geolocation, missions, OTP validation, and real-time notifications.

## Features

### ✅ Implemented
- User registration with phone verification
- Firebase authentication
- Profile management with avatar
- Skill creation with geolocation
- Geolocation-based skill search
- Mission request from skill details
- Mission lifecycle management
- OTP generation and validation
- Real-time notifications
- Credit system display
- Chat (Firebase Firestore)

### 📱 Screens
- Welcome/Splash
- Login/Register
- Complete Profile
- Home Dashboard
- Explore Skills (with map)
- Skill Detail
- Create/Edit Skill
- My Skills
- Request Mission Dialog
- Missions (Requested/Helping tabs)
- Mission Detail (with OTP)
- Notifications
- Settings
- Edit Profile
- Change Password
- Delete Account

## Quick Start

### 1. Install Dependencies
```bash
cd skillswap_front_mobile
flutter pub get
```

### 2. Configure API URL

Edit `lib/core/api_config.dart`:

**For Android Emulator:**
```dart
static const String _androidEmulatorUrl = 'http://10.0.2.2:8080';
```

**For iOS Simulator:**
```dart
static const String _webUrl = 'http://localhost:8080';
```

**For Physical Device:**
```dart
static const String _webUrl = 'http://YOUR_COMPUTER_IP:8080';
```

Find your IP:
```cmd
ipconfig  # Windows
ifconfig  # Mac/Linux
```

### 3. Run App
```bash
flutter run
```

Choose device:
- [1] Android Emulator
- [2] iOS Simulator
- [3] Chrome (web)

## Complete User Flows

### S1 - Registration
1. Open app → Click "Register"
2. Enter: name, email, phone, password
3. Submit form
4. Firebase sends OTP to phone
5. Enter OTP code
6. Account created with 20 credits
7. Welcome notification received

### S2 - Login
1. Open app → Click "Login"
2. Enter email + password
3. Firebase validates
4. JWT token stored
5. Navigate to Home

### S3 - Publish Skill
1. Navigate to "My Skills"
2. Click "+" button
3. Fill form:
   - Title
   - Description
   - Category (dropdown)
   - GPS location (auto-detected)
4. Submit
5. Skill appears in "My Skills"

### S4 - Search Skills
1. Navigate to "Explore Skills"
2. App requests GPS permission
3. Skills loaded within 15km radius
4. Sorted by:
   - Helper Score
   - Distance
5. View on map or list
6. Filter by category

### S5 - View Provider Profile
1. Click on skill card
2. View skill details:
   - Title, description, category
   - Provider name (if enriched)
   - Distance
   - Location (approximate)
3. See "Request Mission" button

### S6 - Chat (Firebase Firestore)
1. Click chat icon on profile
2. Firestore thread created
3. Send/receive messages in real-time
4. Push notifications for new messages

### S7 - Choose Meeting Place
**Current:** Location copied from skill  
**Future:** 
- Select from partner places list
- Pick custom location on map

### S8 - Request Mission
1. On skill detail page
2. Click "Request Mission"
3. Fill dialog:
   - Title (pre-filled)
   - Description
   - Date picker
   - Time picker
   - Duration slider (30-240 min)
   - Credit cost slider (5-50 credits)
4. Submit
5. Credits debited
6. Mission created (PENDING)
7. Provider receives notification

### S9 - Accept/Reject Mission
**Provider Side:**
1. Receive notification
2. Navigate to "My Missions" → "Helping" tab
3. See pending mission
4. Click mission → View details
5. Click "Accept" or "Reject"
6. If accepted:
   - Status → ACCEPTED
   - Requester notified

**Requester Side:**
1. Receive acceptance notification
2. View mission in "Requested" tab
3. Status shows ACCEPTED

### S10 - Navigate to Meeting
1. Open mission detail
2. Click "Navigate" button
3. Maps app opens (supports any installed maps app)
4. Navigate to meeting point

### S11 - OTP Validation
**Provider (Generate OTP):**
1. On mission day, open mission
2. Click "Start Mission"
3. Status → IN_PROGRESS
4. Click "Generate OTP"
5. 6-digit code displayed
6. Show code to requester

**Requester (Validate OTP):**
1. Mission status shows IN_PROGRESS
2. See "Enter OTP" field
3. Type 6-digit code
4. Click "Validate"
5. System verifies OTP
6. Status → COMPLETED
7. Credits transferred

### S12 - Credit Transfer
**Automatic:**
1. OTP validated successfully
2. Provider receives credits
3. Both users receive notification
4. Mission marked COMPLETED
5. Helper Score updated
6. Transaction recorded in Ledger

## Project Structure

```
lib/
├── main.dart
├── auth_service.dart
├── core/
│   ├── api_config.dart
│   ├── app_assets.dart
│   └── app_colors.dart
├── models/
│   ├── user_model.dart
│   ├── skill_model.dart
│   ├── mission_model.dart
│   └── notification_model.dart
├── services/
│   ├── api_service.dart
│   ├── skill_service.dart
│   ├── mission_service.dart
│   └── notification_service.dart
├── providers/
│   └── user_provider.dart
├── pages/
│   ├── welcome_page.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── complete_profile_page.dart
│   ├── home_page.dart
│   ├── explore_skills_page.dart
│   ├── skill_detail_page.dart
│   ├── create_skill_page.dart
│   ├── my_skills_page.dart
│   ├── missions_page.dart
│   ├── mission_detail_page.dart
│   ├── notifications_page.dart
│   ├── settings_page.dart
│   ├── edit_profile_page.dart
│   ├── change_password_page.dart
│   └── delete_account_page.dart
└── widgets/
    └── custom_drawer.dart
```

## API Integration

All API calls go through API Gateway (port 8080):

### Authentication
```dart
POST /api/auth/register
POST /api/auth/login
```

### Skills
```dart
POST   /api/skills
GET    /api/skills/near?lat={lat}&lng={lng}&radius={r}&category={cat}
GET    /api/skills/user/{userId}
PUT    /api/skills/{id}
DELETE /api/skills/{id}
```

### Missions
```dart
POST   /api/missions
GET    /api/missions/user/{userId}?role={REQUESTER|HELPER}&status={status}
POST   /api/missions/{id}/accept
POST   /api/missions/{id}/reject
POST   /api/missions/{id}/start
POST   /api/missions/{id}/generate-otp
POST   /api/missions/{id}/validate-otp
POST   /api/missions/{id}/cancel
```

### Notifications
```dart
GET    /api/notifications
GET    /api/notifications/unread
GET    /api/notifications/unread/count
POST   /api/notifications/{id}/read
POST   /api/notifications/read-all
DELETE /api/notifications/{id}
POST   /api/notifications/token
```

## Firebase Configuration

### 1. Firebase Auth
- Email/Password authentication
- Phone verification with OTP
- JWT token generation

### 2. Firebase Firestore
- Real-time chat threads
- Message synchronization
- Offline support

### 3. Firebase Cloud Messaging (FCM)
- Push notifications
- Token registration
- Background message handling

### Setup
1. Download `google-services.json` (Android)
2. Download `GoogleService-Info.plist` (iOS)
3. Place in respective folders
4. Update `firebase_options.dart`

## State Management

Using **Provider** pattern:

```dart
UserProvider - User profile and authentication state
```

## Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_messaging: ^14.7.9
  cloud_firestore: ^4.13.6
  http: ^1.1.0
  provider: ^6.1.1
  geolocator: ^10.1.0
  flutter_map: ^7.0.2             # OpenStreetMap (free, no API key)
  latlong2: ^0.9.1                 # Lat/Lng utilities
  intl: ^0.18.1
```

## Testing

### Manual Testing Checklist
- [ ] Register new user
- [ ] Verify phone with OTP
- [ ] Login with credentials
- [ ] Create skill with GPS
- [ ] Search nearby skills
- [ ] View skill details
- [ ] Request mission
- [ ] Accept mission (as provider)
- [ ] Start mission
- [ ] Generate OTP
- [ ] Validate OTP
- [ ] Check notifications
- [ ] View credit balance
- [ ] Chat with user

### Test Accounts
Create multiple accounts to test:
- Requester account
- Provider account
- Test mission flow between them

## Troubleshooting

### Cannot Connect to Backend
- Check API URL in `api_config.dart`
- Android emulator: Use `10.0.2.2`
- iOS simulator: Use `localhost`
- Physical device: Use computer's IP
- Verify backend services are running

### GPS Not Working
- Enable location permissions
- Android: Settings → Apps → SkillSwap → Permissions
- iOS: Settings → Privacy → Location Services

### Firebase Auth Errors
- Check `google-services.json` is present
- Verify Firebase project configuration
- Check internet connection

### OTP Not Received
- Verify phone number format
- Check Firebase console for SMS quota
- Test with Firebase test phone numbers

### Notifications Not Showing
- Enable notification permissions
- Register FCM token on login
- Check backend notification service is running
- Verify Firebase Cloud Messaging is enabled

## Performance Optimization

### Image Loading
- Use cached network images
- Compress avatars before upload
- Lazy load skill images

### API Calls
- Cache frequently accessed data
- Debounce search queries
- Pagination for large lists

### GPS
- Cache last known location
- Update location only when needed
- Use coarse location for search

## Security

### API Security
- All requests include JWT token
- Token stored securely
- Auto-refresh on expiration

### Data Validation
- Client-side form validation
- Server-side validation
- Sanitize user inputs

### Privacy
- Exact location never shared
- Only approximate distance shown
- Profile data controlled by user

## Future Enhancements

### Phase 1
- [ ] Offline mode support
- [ ] Image upload for skills
- [ ] Rating and review system
- [ ] Mission history with stats

### Phase 2
- [ ] Partner places integration
- [ ] In-app navigation
- [ ] Video call for remote skills
- [ ] Payment gateway integration

### Phase 3
- [ ] AI skill recommendations
- [ ] Gamification (badges, levels)
- [ ] Social features (follow, share)
- [ ] Multi-language support

## Build & Release

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Support

For issues:
1. Check console logs
2. Verify backend is running
3. Test API endpoints with Postman
4. Check Firebase console
5. Review this documentation

---

**Version:** 1.0.0  
**Platform:** Flutter 3.x  
**Min SDK:** Android 21, iOS 12  
**Status:** Production Ready
