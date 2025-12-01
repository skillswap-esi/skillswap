# Firebase Authentication Integration Guide

## Overview
This document explains the complete Firebase Authentication integration in the SkillSwap mobile application. The app uses Firebase Auth for user management with email/password authentication.

## Table of Contents
1. [Setup & Configuration](#setup--configuration)
2. [Architecture](#architecture)
3. [Authentication Service](#authentication-service)
4. [Features Implemented](#features-implemented)
5. [User Flow](#user-flow)
6. [Error Handling](#error-handling)
7. [Security Considerations](#security-considerations)

---

## Setup & Configuration

### Firebase Initialization
The app initializes Firebase in `main.dart` before running the app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Dependencies
Required packages in `pubspec.yaml`:
- `firebase_core` - Core Firebase functionality
- `firebase_auth` - Firebase Authentication
- `flutter` - Flutter framework

---

## Architecture

### File Structure
```
lib/
├── auth_service.dart           # Authentication service singleton
├── main.dart                   # App entry point with Firebase init
├── pages/
│   ├── welcome_page.dart       # Landing page
│   ├── login_page.dart         # User login
│   ├── register_page.dart      # User registration
│   ├── home_page.dart          # Main app page (authenticated)
│   └── settings_page.dart      # Account management
└── widgets/
    └── custom_drawer.dart      # Navigation drawer with user info
```

---

## Authentication Service

### Location
`lib/auth_service.dart`

### Purpose
Centralized service that handles all Firebase Authentication operations. Uses a `ValueNotifier` pattern for reactive state management.

### Global Instance
```dart
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());
```

### Available Methods

#### 1. **Current User Access**
```dart
User? get currentUser => _firebaseAuth.currentUser;
```
Returns the currently authenticated user or null.

#### 2. **Auth State Stream**
```dart
Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
```
Stream that emits whenever authentication state changes (login/logout).

#### 3. **Sign In**
```dart
Future<UserCredential> signIn({
  required String email,
  required String password,
})
```
Authenticates user with email and password.

**Used in:** `login_page.dart`

#### 4. **Create Account**
```dart
Future<UserCredential> createAccount({
  required String email,
  required String password,
})
```
Creates a new user account with email and password.

**Used in:** `register_page.dart`

#### 5. **Sign Out**
```dart
Future<void> signOut()
```
Signs out the current user.

**Used in:** `custom_drawer.dart` (logout button)

#### 6. **Update Username**
```dart
Future<void> updateUsername({
  required String username,
})
```
Updates the display name of the current user.

**Used in:** `register_page.dart`, `settings_page.dart`

#### 7. **Delete Account**
```dart
Future<void> deleteAccount({
  required String email,
  required String password,
})
```
Permanently deletes the user account after re-authentication.

**Used in:** `settings_page.dart`

#### 8. **Reset Password**
```dart
Future<void> resetPasswordFromCurrentPassword({
  required String currentPassword,
  required String newPassword,
  required String email,
})
```
Changes user password after verifying current password.

**Used in:** `settings_page.dart`

---

## Features Implemented

### 1. User Registration (`register_page.dart`)

**Features:**
- Email and password validation
- Password confirmation matching
- Minimum password length (6 characters)
- Automatic username setup after registration
- Loading state during registration
- Comprehensive error handling

**Flow:**
1. User fills form (name, email, password, confirm password)
2. Form validation
3. Create Firebase account
4. Update display name
5. Navigate to home page

**Error Handling:**
- `weak-password` - Password too weak
- `email-already-in-use` - Email already registered
- `invalid-email` - Invalid email format
- `operation-not-allowed` - Email/password auth disabled

### 2. User Login (`login_page.dart`)

**Features:**
- Email and password input
- Password visibility toggle
- Form validation
- Loading state during login
- "Forgot Password" button (placeholder)
- Navigation to register page

**Flow:**
1. User enters credentials
2. Form validation
3. Firebase authentication
4. Navigate to home page on success

**Error Handling:**
- `user-not-found` - No account with this email
- `wrong-password` - Incorrect password
- `invalid-email` - Invalid email format
- `user-disabled` - Account has been disabled
- `invalid-credential` - Invalid email or password

### 3. Settings Page (`settings_page.dart`)

**Features:**

#### Account Information Display
- Current email address
- Email verification status with visual indicator

#### Update Username
- Text field pre-filled with current username
- Real-time update to Firebase
- Success/error feedback

#### Change Password
- Current password verification
- New password with confirmation
- Password strength validation (min 6 characters)
- Secure re-authentication

#### Delete Account (Danger Zone)
- Email confirmation required
- Password verification
- Double confirmation dialog
- Permanent account deletion
- Automatic sign out and redirect

**Security Features:**
- All sensitive operations require password re-authentication
- Visual danger zone for destructive actions
- Confirmation dialogs for irreversible actions

### 4. User Interface Integration

#### Navigation Drawer (`custom_drawer.dart`)
- Displays real username (first letter as avatar)
- Shows user email
- Settings navigation
- Logout with confirmation dialog

#### Home Page (`home_page.dart`)
- Personalized greeting with username
- Dynamic content based on authenticated user

---

## User Flow

### Registration Flow
```
Welcome Page → Register Page → Create Account → Set Username → Home Page
```

### Login Flow
```
Welcome Page → Login Page → Authenticate → Home Page
```

### Settings Flow
```
Home Page → Drawer → Settings → Update Profile/Password/Delete Account
```

### Logout Flow
```
Any Page → Drawer → Logout → Confirmation → Sign Out → Welcome Page
```

---

## Error Handling

### Strategy
All authentication operations use try-catch blocks with specific Firebase error code handling.

### Error Display
- User-friendly error messages via `SnackBar`
- Color-coded feedback (red for errors, green for success)
- Specific messages for each error type

### Common Error Codes

| Error Code | Meaning | User Message |
|------------|---------|--------------|
| `user-not-found` | No account exists | "No user found with this email" |
| `wrong-password` | Incorrect password | "Wrong password provided" |
| `email-already-in-use` | Email taken | "An account already exists for this email" |
| `weak-password` | Password too simple | "The password provided is too weak" |
| `invalid-email` | Bad email format | "Invalid email address" |
| `requires-recent-login` | Session expired | "Please logout and login again" |
| `user-disabled` | Account disabled | "This account has been disabled" |

### Loading States
All async operations show loading indicators:
- Buttons disabled during processing
- Circular progress indicator replaces button text
- Prevents duplicate submissions

---

## Security Considerations

### Password Requirements
- Minimum 6 characters (Firebase default)
- Validated on both client and server side

### Re-authentication
Sensitive operations require password re-entry:
- Password changes
- Account deletion

### Data Validation
- Email format validation
- Password matching confirmation
- Empty field checks
- Trim whitespace from inputs

### Session Management
- Automatic session handling by Firebase
- Auth state persistence across app restarts
- Secure token management

### Best Practices Implemented
1. **Never store passwords** - Only sent to Firebase
2. **Immediate feedback** - Users know operation status
3. **Confirmation dialogs** - Prevent accidental destructive actions
4. **Mounted checks** - Prevent setState on disposed widgets
5. **Error specificity** - Clear error messages without exposing system details

---

## Testing Checklist

### Registration
- [ ] Valid email and password creates account
- [ ] Duplicate email shows error
- [ ] Weak password shows error
- [ ] Password mismatch shows error
- [ ] Username is set correctly

### Login
- [ ] Valid credentials log in successfully
- [ ] Invalid credentials show error
- [ ] Wrong password shows specific error
- [ ] Non-existent email shows error

### Settings
- [ ] Username updates successfully
- [ ] Password change with correct current password works
- [ ] Password change with wrong current password fails
- [ ] Account deletion requires confirmation
- [ ] Account deletion with wrong password fails

### UI/UX
- [ ] Loading states show during operations
- [ ] Error messages are clear and helpful
- [ ] Success messages confirm operations
- [ ] Navigation flows work correctly
- [ ] User data displays in drawer and home page

---

## Future Enhancements

### Potential Features
1. **Email Verification** - Send verification emails
2. **Password Reset** - Forgot password functionality
3. **Social Auth** - Google, Apple, Facebook login
4. **Profile Photos** - Upload and display user avatars
5. **Two-Factor Authentication** - Enhanced security
6. **Account Recovery** - Email-based account recovery
7. **Session Timeout** - Auto-logout after inactivity

### Code Improvements
1. **Form Validation Package** - Use `flutter_form_builder`
2. **State Management** - Consider Provider or Riverpod
3. **Error Logging** - Implement Firebase Crashlytics
4. **Analytics** - Track user authentication events
5. **Unit Tests** - Test auth service methods
6. **Widget Tests** - Test UI components

---

## Troubleshooting

### Common Issues

**Issue:** "Firebase not initialized"
- **Solution:** Ensure `Firebase.initializeApp()` is called before `runApp()`

**Issue:** "Email/password sign-in is disabled"
- **Solution:** Enable Email/Password auth in Firebase Console

**Issue:** "requires-recent-login" error
- **Solution:** User needs to logout and login again before sensitive operations

**Issue:** User data not showing in UI
- **Solution:** Ensure `authService.value.currentUser` is accessed after authentication

**Issue:** Navigation errors after logout
- **Solution:** Use `pushAndRemoveUntil` to clear navigation stack

---

## Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/auth/overview)
- [Firebase Console](https://console.firebase.google.com/)

---

## Support

For issues or questions about this implementation:
1. Check Firebase Console for authentication logs
2. Review error messages in the app
3. Verify Firebase configuration in `firebase_options.dart`
4. Ensure all dependencies are up to date

---

**Last Updated:** November 27, 2025
**Version:** 1.0.0
**Author:** SkillSwap Development Team
