# SkillSwap Mobile App - Flutter Application

## 📋 Overview

SkillSwap Mobile is a cross-platform Flutter application that enables users to exchange skills through a credit-based mission system. The app features real-time chat, geolocation-based skill discovery, push notifications, and OTP-validated mission completion.

## 🏗️ Architecture

### Application Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │   Pages    │  │  Widgets   │  │  Services  │           │
│  │            │  │            │  │            │           │
│  │ - Login    │  │ - Drawer   │  │ - API      │           │
│  │ - Home     │  │ - Cards    │  │ - Auth     │           │
│  │ - Skills   │  │ - Dialogs  │  │ - Chat     │           │
│  │ - Missions │  │ - Lists    │  │ - FCM      │           │
│  │ - Chat     │  │            │  │ - Mission  │           │
│  └────────────┘  └────────────┘  └────────────┘           │
│         │               │               │                   │
│         └───────────────┴───────────────┘                   │
│                         │                                   │
│                         ▼                                   │
│              ┌────────────────────┐                        │
│              │  State Management  │                        │
│              │    (Provider)      │                        │
│              └────────────────────┘                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┬──────────────┐
        │              │              │              │
        ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐
│ API Gateway  │ │ Firebase │ │Firestore │ │   Firebase   │
│   (REST)     │ │  Auth    │ │  (Chat)  │ │  Messaging   │
│   :8080      │ │          │ │          │ │    (FCM)     │
└──────────────┘ └──────────┘ └──────────┘ └──────────────┘
```

### Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Pages   │  │ Widgets  │  │ Dialogs  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────┐
│                   Business Logic Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Providers │  │ Services │  │  Models  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │   HTTP   │  │ Firebase │  │Firestore │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

## 🎯 Features

### ✅ Implemented Features

#### Authentication & User Management
- **Firebase Authentication**: Email/password and phone verification
- **User Registration**: With phone OTP verification
- **Profile Management**: Avatar, name, bio, skills
- **Credit System**: View balance, transaction history
- **Helper Score**: Reputation system based on completed missions

#### Skill Management
- **Create Skills**: With title, description, category, GPS location
- **My Skills**: View and manage owned skills
- **Explore Skills**: Geolocation-based search (15km radius)
- **Skill Details**: View provider info, distance, ratings
- **Categories**: INFORMATIQUE, CUISINE, JARDINAGE, BRICOLAGE, SCOLAIRE, SPORT, MUSIQUE, LANGUES, AUTRE

#### Mission System
- **Request Mission**: Book skills with date, time, duration, credits
- **Mission Lifecycle**: PENDING → ACCEPTED → IN_PROGRESS → COMPLETED
- **Accept/Reject**: Providers can accept or reject requests
- **OTP Validation**: 6-digit code for mission completion
- **Credit Transfer**: Automatic on OTP validation
- **Mission History**: View all requested and helping missions
- **Cancel Mission**: With reason

#### Real-Time Chat
- **Firestore Integration**: Real-time message synchronization
- **Chat Threads**: One-to-one conversations
- **Message History**: Persistent chat storage
- **Typing Indicators**: Real-time presence
- **Offline Support**: Messages sync when online

#### Notifications
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Notification Types**: Mission updates, chat messages, credits
- **Notification Center**: View all notifications
- **Badge Count**: Unread notification counter
- **Background Handling**: Receive notifications when app is closed

#### Geolocation & Maps
- **GPS Detection**: Automatic location detection
- **Map View**: OpenStreetMap integration (no API key required)
- **Skill Markers**: Display skills on map
- **Distance Calculation**: Show distance to skills
- **Navigation**: Open external maps app for directions

### 📱 Screens

#### Authentication Flow
1. **Welcome Page**: App introduction and navigation
2. **Login Page**: Email/password authentication
3. **Register Page**: New user registration with phone
4. **Complete Profile Page**: Avatar and additional info

#### Main Flow
5. **Home Page**: Dashboard with 4 tabs (Home, Explore, Chats, Profile)
6. **Explore Skills Page**: Search and filter skills
7. **Skill Detail Page**: View skill and request mission
8. **Create Skill Page**: Publish new skill
9. **My Skills Page**: Manage owned skills

#### Mission Flow
10. **Missions Page**: View requested and helping missions
11. **Mission Detail Page**: Mission info, OTP, actions
12. **Create Mission Page**: Request mission dialog

#### Communication
13. **Chats List Page**: All conversations (placeholder)
14. **Chat Page**: Real-time messaging
15. **Notifications Page**: Notification center

#### Settings
16. **Profile Page**: View and edit profile (placeholder)
17. **Settings Page**: App preferences
18. **Edit Profile Page**: Update user information
19. **Change Password Page**: Security settings
20. **Delete Account Page**: Account deletion

## 🛠️ Technology Stack

### Core Technologies
- **Flutter**: 3.x
- **Dart**: 3.x
- **Minimum SDK**: Android 21 (5.0), iOS 12

### State Management
- **Provider**: ^6.1.1 - Reactive state management
- **ChangeNotifier**: For user state and authentication

### Backend Integration
- **http**: ^1.1.0 - REST API communication
- **API Gateway**: http://localhost:8080 (configurable)

### Firebase Services
- **firebase_core**: ^2.24.2 - Firebase initialization
- **firebase_auth**: ^4.15.3 - Authentication
- **cloud_firestore**: ^4.13.6 - Real-time database (chat)
- **firebase_messaging**: ^14.7.9 - Push notifications (FCM)

### Geolocation & Maps
- **geolocator**: ^10.1.0 - GPS location services
- **flutter_map**: ^7.0.2 - OpenStreetMap integration (free, no API key)
- **latlong2**: ^0.9.1 - Latitude/longitude utilities

### UI & Utilities
- **intl**: ^0.18.1 - Date/time formatting and internationalization
- **Material Design**: Flutter's built-in UI framework

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── auth_service.dart                  # Authentication service
│
├── core/                              # Core configuration
│   ├── api_config.dart               # API URLs and configuration
│   ├── app_assets.dart               # Asset paths
│   └── app_colors.dart               # Color palette
│
├── models/                            # Data models
│   ├── user_model.dart               # User entity
│   ├── skill_model.dart              # Skill entity
│   ├── mission_model.dart            # Mission entity
│   ├── notification_model.dart       # Notification entity
│   └── chat_model.dart               # Chat message entity
│
├── services/                          # Business logic services
│   ├── api_service.dart              # HTTP client wrapper
│   ├── skill_service.dart            # Skill API calls
│   ├── mission_service.dart          # Mission API calls
│   ├── notification_service.dart     # Notification API calls
│   ├── chat_service.dart             # Firestore chat operations
│   └── fcm_service.dart              # Push notification handling
│
├── providers/                         # State management
│   └── user_provider.dart            # User state provider
│
├── pages/                             # UI screens
│   ├── welcome_page.dart             # Splash/welcome screen
│   ├── login_page.dart               # Login form
│   ├── register_page.dart            # Registration form
│   ├── complete_profile_page.dart    # Profile completion
│   ├── home_page.dart                # Main dashboard (4 tabs)
│   ├── explore_skills_page.dart      # Skill search and list
│   ├── skill_detail_page.dart        # Skill details
│   ├── create_skill_page.dart        # Create new skill
│   ├── my_skills_page.dart           # User's skills
│   ├── missions_page.dart            # Mission list (2 tabs)
│   ├── mission_detail_page.dart      # Mission details and OTP
│   ├── create_mission_page.dart      # Request mission
│   ├── chats_list_page.dart          # Chat list (placeholder)
│   ├── chat_page.dart                # Real-time chat
│   ├── notifications_page.dart       # Notification center
│   ├── profile_page.dart             # User profile (placeholder)
│   ├── simple_profile_page.dart      # Simple profile view
│   ├── settings_page.dart            # App settings
│   ├── edit_profile_page.dart        # Edit profile form
│   ├── change_password_page.dart     # Change password
│   ├── delete_account_page.dart      # Delete account
│   └── map_picker_page.dart          # Location picker
│
└── widgets/                           # Reusable components
    ├── custom_drawer.dart            # Navigation drawer
    └── notifications_panel.dart      # Notification panel
```

## 🔄 Data Flow

### Authentication Flow
```
1. User enters credentials
2. AuthService validates with Firebase
3. Firebase returns ID token
4. App calls /api/auth/login with Firebase token
5. Backend validates and returns JWT
6. JWT stored in memory
7. UserProvider updates state
8. Navigate to Home
```

### Skill Search Flow
```
1. User opens Explore tab
2. Geolocator gets current position
3. SkillService calls /api/skills/near
4. Backend queries MongoDB with $near
5. Results enriched with user data
6. Skills displayed on map and list
7. User can filter by category
```

### Mission Request Flow
```
1. User views skill detail
2. Clicks "Request Mission"
3. Fills mission form (date, time, duration, credits)
4. MissionService calls /api/missions
5. Backend creates mission (PENDING)
6. Credits debited from requester
7. Kafka event triggers notification
8. Provider receives FCM push
9. Mission appears in provider's "Helping" tab
```

### OTP Validation Flow
```
1. Provider opens mission detail
2. Clicks "Generate OTP"
3. Backend generates 6-digit code
4. Code stored in Redis (5 min TTL)
5. Provider shows code to requester
6. Requester enters code in app
7. MissionService validates OTP
8. Mission status → COMPLETED
9. Credits transferred
10. Both users receive notification
```

### Chat Flow
```
1. User clicks chat icon
2. ChatService creates/gets Firestore thread
3. Thread ID: {userId1}_{userId2}_{skillId}
4. Messages synced in real-time
5. New message triggers FCM notification
6. Offline messages sync when online
```

## 🔐 Security

### Authentication
- **Firebase Authentication**: Secure email/password and phone verification
- **JWT Tokens**: Stored in memory (not persisted)
- **Token Refresh**: Automatic on expiration
- **Secure Storage**: Sensitive data encrypted

### API Security
- **HTTPS**: All API calls over TLS (production)
- **JWT Header**: `Authorization: Bearer {token}`
- **User ID Validation**: Backend validates user identity
- **Rate Limiting**: Backend enforces rate limits

### Data Privacy
- **Location Privacy**: Exact location never shared with other users
- **Approximate Distance**: Only distance shown, not coordinates
- **Profile Control**: Users control what information is public
- **Chat Encryption**: Firestore security rules enforce access control

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Chat threads accessible only to participants
    match /chat_threads/{threadId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.firebaseUids;
    }
    
    // Messages accessible only to thread participants
    match /chat_threads/{threadId}/messages/{messageId} {
      allow read: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.firebaseUids;
      allow create: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chat_threads/$(threadId)).data.firebaseUids;
    }
  }
}
```

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / Xcode
- Firebase project
- Backend services running

### 1. Install Flutter
```bash
# Download Flutter SDK
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

### 2. Clone and Install Dependencies
```bash
cd skillswap_front_mobile
flutter pub get
```

### 3. Configure API URL

Edit `lib/core/api_config.dart`:

```dart
class ApiConfig {
  // For Android Emulator
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8080';
  
  // For iOS Simulator
  static const String _iosSimulatorUrl = 'http://localhost:8080';
  
  // For Physical Device (use your computer's IP)
  static const String _physicalDeviceUrl = 'http://192.168.1.100:8080';
  
  // For Web
  static const String _webUrl = 'http://localhost:8080';
}
```

**Find Your IP Address**:
```bash
# Windows
ipconfig

# Mac/Linux
ifconfig
```

### 4. Configure Firebase

#### Android
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/GoogleService-Info.plist`

#### Update Firebase Options
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 5. Deploy Firestore Rules
```bash
# From skillswap_front_mobile directory
firebase deploy --only firestore:rules
```

### 6. Run the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run

# Run in release mode
flutter run --release
```

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Manual Testing Checklist
- [ ] Register new user with phone verification
- [ ] Login with existing credentials
- [ ] Create skill with GPS location
- [ ] Search nearby skills
- [ ] View skill details
- [ ] Request mission
- [ ] Accept mission (as provider)
- [ ] Generate OTP
- [ ] Validate OTP
- [ ] Send chat message
- [ ] Receive push notification
- [ ] View credit balance
- [ ] Update profile

## 🐛 Troubleshooting

### Cannot Connect to Backend
**Problem**: API calls fail with connection error

**Solutions**:
1. Check API URL in `api_config.dart`
2. Android emulator: Use `10.0.2.2` instead of `localhost`
3. iOS simulator: Use `localhost`
4. Physical device: Use computer's IP address
5. Verify backend services are running
6. Check firewall settings

### GPS Not Working
**Problem**: Location services not available

**Solutions**:
1. Enable location permissions in device settings
2. Android: Settings → Apps → SkillSwap → Permissions → Location
3. iOS: Settings → Privacy → Location Services → SkillSwap
4. Check `geolocator` package configuration
5. Test on physical device (emulator GPS may be unreliable)

### Firebase Auth Errors
**Problem**: Authentication fails

**Solutions**:
1. Verify `google-services.json` / `GoogleService-Info.plist` is present
2. Check Firebase project configuration
3. Ensure email/password auth is enabled in Firebase Console
4. Verify internet connection
5. Check Firebase quota limits

### OTP Not Received
**Problem**: SMS OTP not delivered

**Solutions**:
1. Verify phone number format (+country code)
2. Check Firebase Console for SMS quota
3. Use Firebase test phone numbers for development
4. Verify phone authentication is enabled
5. Check SMS provider configuration

### Notifications Not Showing
**Problem**: Push notifications not received

**Solutions**:
1. Enable notification permissions
2. Register FCM token on login
3. Check backend notification service is running
4. Verify Firebase Cloud Messaging is enabled
5. Test on physical device (emulator FCM may not work)
6. Check FCM token is stored in backend

### Firestore Permission Denied
**Problem**: Chat messages fail to send

**Solutions**:
1. Deploy Firestore security rules
2. Verify user is authenticated
3. Check Firebase UID is in `firebaseUids` array
4. Review Firestore rules in Firebase Console
5. Check internet connection

### Build Errors
**Problem**: App fails to build

**Solutions**:
```bash
# Clean build
flutter clean
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for conflicts
flutter doctor

# Rebuild
flutter run
```

## 📊 Performance Optimization

### Image Loading
- Use `CachedNetworkImage` for avatars
- Compress images before upload
- Lazy load skill images
- Implement image placeholders

### API Calls
- Cache frequently accessed data
- Debounce search queries
- Implement pagination for large lists
- Use pull-to-refresh pattern

### GPS & Location
- Cache last known location
- Update location only when needed
- Use coarse location for search
- Implement location permission handling

### State Management
- Use Provider for reactive updates
- Avoid unnecessary rebuilds
- Implement proper dispose methods
- Use const constructors where possible

## 🚢 Build & Release

### Android Release
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output location
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### iOS Release
```bash
# Build iOS app
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
# Product → Archive
```

### Web Release
```bash
# Build web app
flutter build web --release

# Output location
build/web/
```

## 📈 Future Enhancements

### Phase 1 (Q1 2026)
- [ ] Offline mode support
- [ ] Image upload for skills
- [ ] Rating and review system
- [ ] Mission history with statistics
- [ ] Advanced search filters

### Phase 2 (Q2 2026)
- [ ] Partner places integration
- [ ] In-app navigation
- [ ] Video call for remote skills
- [ ] Payment gateway integration
- [ ] Multi-language support

### Phase 3 (Q3 2026)
- [ ] AI skill recommendations
- [ ] Gamification (badges, levels)
- [ ] Social features (follow, share)
- [ ] Advanced analytics dashboard
- [ ] Dark mode

## 📚 Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Map](https://pub.dev/packages/flutter_map)

### Tutorials
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Firebase with Flutter](https://firebase.google.com/docs/flutter/setup)
- [State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

## 🤝 Contributing

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add comments for complex logic
- Format code with `dart format`

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature
```

## 📄 License

Private Project - All Rights Reserved

---

**Version**: 1.0.0  
**Platform**: Flutter 3.x  
**Min SDK**: Android 21, iOS 12  
**Status**: Production Ready  
**Last Updated**: January 2026
