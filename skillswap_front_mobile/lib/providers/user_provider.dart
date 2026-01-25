import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../auth_service.dart';

/// User Provider for managing user state across the app
/// 
/// This provider holds the current user's profile data from the backend
/// and provides methods to update it.
class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  /// The current user profile
  UserModel? get user => _user;

  /// Whether user data is being loaded
  bool get isLoading => _isLoading;

  /// Any error that occurred
  String? get error => _error;

  /// Whether a user is loaded
  bool get hasUser => _user != null;

  /// User's display name (from backend or Firebase fallback)
  String get displayName {
    if (_user?.fullName != null && _user!.fullName.isNotEmpty) {
      return _user!.fullName;
    }
    return authService.value.currentUser?.displayName ?? 'User';
  }

  /// User's email
  String get email {
    return _user?.email ?? authService.value.currentUser?.email ?? '';
  }

  /// User's credit balance
  int get creditsBalance => _user?.creditsBalance ?? 0;

  /// User's helper score
  double get helperScore => _user?.helperScore ?? 0.0;

  /// Whether user's phone is verified
  bool get isPhoneVerified => _user?.phoneVerified ?? false;

  /// Set the user from auth service
  void setUser(UserModel? user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  /// Refresh user data from the backend
  Future<void> refreshUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await authService.value.refreshUserProfile();
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear user data (on logout)
  void clear() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Sync user from auth service
  void syncFromAuthService() {
    _user = authService.value.userProfile;
    notifyListeners();
  }
}

/// Global user provider instance
/// For a production app, consider using Provider package or Riverpod
final userProvider = UserProvider();
