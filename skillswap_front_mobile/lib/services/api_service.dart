import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/user_model.dart';

/// API Exception for handling HTTP errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Check if this is a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Check if this is a server error (5xx)
  bool get isServerError => statusCode >= 500;

  /// Check if this is a network error
  bool get isNetworkError => statusCode == 0;
}

/// Main API Service for communicating with the SkillSwap backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  
  /// Headers for JSON requests
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with authentication token
  Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Bearer $token',
  };

  /// Base URL for the API
  String get _baseUrl => ApiConfig.userServiceUrl;

  /// Handle API response and throw ApiException if needed
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String message = 'Unknown error';
      dynamic data;
      
      try {
        final body = json.decode(response.body);
        message = body['message'] ?? body['error'] ?? 'Unknown error';
        data = body;
      } catch (_) {
        message = response.body.isNotEmpty ? response.body : 'Unknown error';
      }
      
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
        data: data,
      );
    }
  }

  /// Wrap API calls with error handling
  Future<T> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'HTTP Error: ${e.message}',
      );
    } on FormatException {
      throw ApiException(
        statusCode: 0,
        message: 'Invalid response format from server.',
      );
    }
  }

  // ==================== Auth Service APIs ====================

  /// Register a new user after Firebase authentication
  /// This is called after the user registers with Firebase
  Future<UserModel> register({
    required String email,
    required String fullName,
    String? phoneNumber,
    required String idToken,
  }) async {
    return _safeApiCall(() async {
      // Debug logging
      print('=== REGISTER API CALL ===');
      print('Base URL: $_baseUrl');
      print('Endpoint: ${AuthEndpoints.register}');
      print('Full URL: $_baseUrl${AuthEndpoints.register}');
      print('Email: $email');
      print('Full Name: $fullName');
      print('Token length: ${idToken.length}');
      print('Token (first 50 chars): ${idToken.length > 50 ? idToken.substring(0, 50) : idToken}...');
      
      final request = {
        'email': email,
        'fullName': fullName,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
        'idToken': idToken,
      };

      print('Request body: ${json.encode(request).substring(0, 200)}...');

      final response = await _client.post(
        Uri.parse('$_baseUrl${AuthEndpoints.register}'),
        headers: _jsonHeaders,
        body: json.encode(request),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Login an existing user after Firebase authentication
  /// This is called after the user logs in with Firebase
  Future<UserModel> login({
    required String email,
    required String idToken,
  }) async {
    return _safeApiCall(() async {
      final request = {
        'email': email,
        'idToken': idToken,
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl${AuthEndpoints.login}'),
        headers: _jsonHeaders,
        body: json.encode(request),
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  // ==================== User Service APIs ====================

  /// Create a new user profile after Firebase authentication
  /// This is called after the user registers with Firebase
  Future<UserModel> createProfile({
    required String email,
    required String fullName,
    String? phoneNumber,
    required String idToken,
  }) async {
    return _safeApiCall(() async {
      final request = CreateProfileRequest(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        idToken: idToken,
      );

      final response = await _client.post(
        Uri.parse('$_baseUrl${UserEndpoints.profile}'),
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Get the current user's profile
  Future<UserModel> getCurrentUser({
    required String userId,
    String? authToken,
  }) async {
    return _safeApiCall(() async {
      final uri = Uri.parse('$_baseUrl${UserEndpoints.me}').replace(
        queryParameters: {'userId': userId},
      );

      final response = await _client.get(
        uri,
        headers: authToken != null ? _authHeaders(authToken) : _jsonHeaders,
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Get a user by their ID
  Future<UserModel> getUserById(String userId) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl${UserEndpoints.byId(userId)}'),
        headers: _jsonHeaders,
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Get a user by their email
  Future<UserModel> getUserByEmail(String email) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl${UserEndpoints.byEmail(email)}'),
        headers: _jsonHeaders,
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Update the current user's profile
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? avatar,
  }) async {
    return _safeApiCall(() async {
      final request = UpdateProfileRequest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatar: avatar,
      );

      final uri = Uri.parse('$_baseUrl${UserEndpoints.me}').replace(
        queryParameters: {'userId': userId},
      );

      final response = await _client.put(
        uri,
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Verify the user's phone number (awards bonus credits)
  Future<UserModel> verifyPhone(String userId) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl${UserEndpoints.verifyPhone(userId)}'),
        headers: _jsonHeaders,
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data);
    });
  }

  /// Save FCM token for push notifications
  Future<void> saveFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    return _safeApiCall(() async {
      final uri = Uri.parse('$_baseUrl${UserEndpoints.fcmTokens}').replace(
        queryParameters: {'userId': userId},
      );

      final response = await _client.post(
        uri,
        headers: _jsonHeaders,
        body: json.encode({'fcmToken': fcmToken}),
      );

      _handleResponse(response);
    });
  }

  /// Get ledger (credit) transactions for a user
  Future<List<LedgerTransaction>> getLedgerTransactions({
    required String userId,
    int limit = 50,
  }) async {
    return _safeApiCall(() async {
      final uri = Uri.parse('$_baseUrl${UserEndpoints.ledger}').replace(
        queryParameters: {
          'userId': userId,
          'limit': limit.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: _jsonHeaders,
      );

      final data = _handleResponse(response) as List;
      return data.map((e) => LedgerTransaction.fromJson(e)).toList();
    });
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Global API service instance
final apiService = ApiService();
