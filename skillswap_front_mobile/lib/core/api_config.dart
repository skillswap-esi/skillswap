// API Configuration for SkillSwap Backend
// 
// This file contains the base URLs and endpoints for connecting
// to the SkillSwap microservices backend.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for SkillSwap Backend
class ApiConfig {
  // Base URLs - Update these for your environment
  // For development with Android emulator, use 10.0.2.2 instead of localhost
  // For iOS simulator, use localhost or 127.0.0.1
  // For web, use localhost
  // For physical devices, use your machine's IP address
  
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8080'; // Android emulator → API Gateway
  static const String _webUrl = 'http://localhost:8080'; // Web/iOS → API Gateway
  static const String _prodBaseUrl = 'https://api.skillswap.com'; // Production
  
  // ⚠️ UPDATE THIS with your machine's IP when testing on real device
  // Find your IP: Windows → ipconfig | Linux/Mac → ifconfig
  static const String _physicalDeviceUrl = 'http://10.23.99.211:8080'; // Your machine's IP
  
  // Current environment
  static const bool isProduction = false;
  
  // Set to true when testing on a real physical Android device
  static const bool usePhysicalDevice = true;
  
  /// Get the appropriate base URL based on platform and environment
  static String get baseUrl {
    if (isProduction) {
      return _prodBaseUrl;
    }
    
    // Detect platform and return appropriate URL
    if (kIsWeb) {
      // Running on web (Chrome, Firefox, etc.)
      return _webUrl;
    } else {
      try {
        // Running on mobile/desktop
        if (Platform.isAndroid) {
          // Use physical device URL if flag is set, otherwise use emulator URL
          return usePhysicalDevice ? _physicalDeviceUrl : _androidEmulatorUrl;
        } else {
          // iOS simulator, macOS, Windows, Linux use localhost
          return _webUrl;
        }
      } catch (e) {
        // Fallback to web URL if platform detection fails
        return _webUrl;
      }
    }
  }
  
  // API Gateway is the single entry point (Port 8080)
  static String get apiGatewayUrl => baseUrl;
  
  // All services go through API Gateway
  static String get userServiceUrl => '$apiGatewayUrl/api';
  static String get skillServiceUrl => '$apiGatewayUrl/api';
  static String get missionServiceUrl => '$apiGatewayUrl/api';
  static String get notificationServiceUrl => '$apiGatewayUrl/api';
}

/// API Endpoints for the User Service
class UserEndpoints {
  static const String base = '/users';
  
  // Profile endpoints
  static const String profile = '$base/profile';
  static const String me = '$base/me';
  
  // Phone verification
  static String verifyPhone(String userId) => '$base/$userId/verify-phone';
  
  // FCM Token
  static const String fcmTokens = '$base/fcm-tokens';
  
  // Ledger / Credits
  static const String ledger = '$base/ledger';
  static String addCredits(String userId) => '$base/$userId/credits/add';
  static String deductCredits(String userId) => '$base/$userId/credits/deduct';
  static const String transferCredits = '$base/credits/transfer';
  
  // User lookup
  static String byId(String userId) => '$base/$userId';
  static String byEmail(String email) => '$base/email/$email';
}

/// API Endpoints for Authentication
class AuthEndpoints {
  static const String base = '/auth';
  
  static const String register = '$base/register';
  static const String login = '$base/login';
  static const String verifyToken = '$base/verify-token';
}

/// API Endpoints for the Skill Service
class SkillEndpoints {
  static const String base = '/skills';
  
  static const String all = base;
  static String byId(String skillId) => '$base/$skillId';
  static String byUser(String userId) => '$base/user/$userId';
  static const String near = '$base/near';
  static const String categories = '$base/categories';
  static const String search = '$base/search';
}

/// API Endpoints for the Mission Service
class MissionEndpoints {
  static const String base = '/missions';
  
  static const String all = base;
  static String byId(String missionId) => '$base/$missionId';
  static String accept(String missionId) => '$base/$missionId/accept';
  static String reject(String missionId) => '$base/$missionId/reject';
  static String generateOtp(String missionId) => '$base/$missionId/otp';
  static String validateOtp(String missionId) => '$base/$missionId/validate';
}
