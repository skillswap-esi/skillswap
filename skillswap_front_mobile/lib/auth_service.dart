import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

/// Global auth service instance
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

/// Authentication Service
/// 
/// This service handles authentication using Firebase Auth on the client side,
/// but all token verification and user profile management is done via the backend.
/// 
/// Flow:
/// 1. User signs in/registers with Firebase Auth (client-side)
/// 2. Firebase returns an ID token
/// 3. The ID token is sent to the backend for verification
/// 4. Backend verifies the token using Firebase Admin SDK
/// 5. Backend creates/retrieves user profile and returns it
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  /// The current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// The current user's profile from the backend
  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Check if user has a backend profile
  bool get hasProfile => _userProfile != null;

  /// Get the current Firebase ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  /// Sign in with email and password
  /// After Firebase auth, syncs with backend
  /// 
  /// Flow:
  /// 1. User logs in → Firebase Auth
  /// 2. Firebase returns JWT
  /// 3. App calls POST /auth/login (with JWT)
  /// 4. Backend retrieves or creates MongoDB User document
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get Firebase ID token
    final idToken = await credential.user?.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get Firebase ID token');
    }

    // Login to backend (retrieves or creates MongoDB profile)
    try {
      _userProfile = await apiService.login(
        email: email,
        idToken: idToken,
      );
      debugPrint('User logged in: ${_userProfile?.userId}');
    } catch (e) {
      debugPrint('Failed to login to backend: $e');
      // Continue anyway - user is authenticated with Firebase
    }

    return credential;
  }

  /// Create a new account with email and password
  /// After Firebase auth, creates profile in backend
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register a new user and create their backend profile
  /// This is the main registration method that handles both Firebase and backend
  /// 
  /// Flow:
  /// 1. User signs up → Firebase Auth
  /// 2. Firebase returns JWT
  /// 3. App calls POST /auth/register (with JWT)
  /// 4. API Gateway verifies JWT
  /// 5. service-user creates MongoDB User document
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    debugPrint('=== REGISTER FLOW START ===');
    
    // 1. Create Firebase account
    debugPrint('Step 1: Creating Firebase account...');
    final credential = await createAccount(
      email: email,
      password: password,
    );
    debugPrint('Firebase account created. User UID: ${credential.user?.uid}');

    // 2. Update display name in Firebase
    debugPrint('Step 2: Updating display name...');
    await credential.user?.updateDisplayName(fullName);

    // 3. Get the Firebase ID token
    debugPrint('Step 3: Getting Firebase ID token...');
    final idToken = await credential.user?.getIdToken();
    if (idToken == null) {
      debugPrint('ERROR: Failed to get Firebase ID token!');
      throw Exception('Failed to get Firebase ID token');
    }
    debugPrint('Firebase ID token obtained. Length: ${idToken.length}');
    debugPrint('Token preview: ${idToken.substring(0, 50)}...');

    // 4. Register in backend (creates MongoDB profile)
    debugPrint('Step 4: Registering in backend...');
    try {
      _userProfile = await apiService.register(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        idToken: idToken,
      );
      debugPrint('SUCCESS! Backend profile created: ${_userProfile?.userId}');
      return _userProfile!;
    } catch (e) {
      // If backend profile creation fails, delete Firebase account
      debugPrint('FAILED to create backend profile: $e');
      await credential.user?.delete();
      rethrow;
    }
  }



  /// Refresh the user profile from the backend
  Future<UserModel?> refreshUserProfile() async {
    if (currentUser == null || _userProfile?.userId == null) {
      return null;
    }

    try {
      _userProfile = await apiService.getUserById(_userProfile!.userId!);
      return _userProfile;
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
      return null;
    }
  }

  /// Update the user's profile in the backend
  Future<UserModel?> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatar,
  }) async {
    if (_userProfile?.userId == null) {
      throw Exception('No user profile to update');
    }

    try {
      // Update in backend
      _userProfile = await apiService.updateProfile(
        userId: _userProfile!.userId!,
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatar: avatar,
      );

      // Also update display name in Firebase if changed
      if (fullName != null && currentUser != null) {
        await currentUser!.updateDisplayName(fullName);
      }

      return _userProfile;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _userProfile = null;
    await _firebaseAuth.signOut();
  }

  /// Update username (display name)
  Future<void> updateUsername({required String username}) async {
    await currentUser?.updateDisplayName(username);
    
    // Also update in backend if we have a profile
    if (_userProfile?.userId != null) {
      await updateProfile(fullName: username);
    }
  }

  /// Delete the user's account
  /// Deletes from both Firebase and backend
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    // Re-authenticate first
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    
    // TODO: Add backend endpoint to delete user account
    // await apiService.deleteAccount(_userProfile?.userId);
    
    // Delete from Firebase
    await currentUser!.delete();
    
    // Clear local state
    _userProfile = null;
    await _firebaseAuth.signOut();
  }

  /// Reset password with current password
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  /// Verify phone number (awards bonus credits from backend)
  Future<UserModel?> verifyPhone() async {
    if (_userProfile?.userId == null) {
      throw Exception('No user profile to verify phone for');
    }

    try {
      _userProfile = await apiService.verifyPhone(_userProfile!.userId!);
      return _userProfile;
    } catch (e) {
      debugPrint('Error verifying phone: $e');
      rethrow;
    }
  }

  /// Save FCM token for push notifications
  Future<void> saveFcmToken(String fcmToken) async {
    if (_userProfile?.userId == null) {
      throw Exception('No user profile to save FCM token for');
    }

    try {
      await apiService.saveFcmToken(
        userId: _userProfile!.userId!,
        fcmToken: fcmToken,
      );
      debugPrint('FCM token saved successfully');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Get ledger transactions for the current user
  Future<List<LedgerTransaction>> getLedgerTransactions({int limit = 50}) async {
    if (_userProfile?.userId == null) {
      throw Exception('No user profile to get transactions for');
    }

    return await apiService.getLedgerTransactions(
      userId: _userProfile!.userId!,
      limit: limit,
    );
  }
}
