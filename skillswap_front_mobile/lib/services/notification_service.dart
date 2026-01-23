import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders(String authToken) => {
        ..._jsonHeaders,
        'Authorization': 'Bearer $authToken',
      };

  String get _baseUrl => '${ApiConfig.baseUrl}/notifications';

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String message = 'Unknown error';
      try {
        final body = json.decode(response.body);
        message = body['message'] ?? body['error'] ?? 'Unknown error';
      } catch (_) {
        message = response.body.isNotEmpty ? response.body : 'Unknown error';
      }
      throw NotificationServiceException(
        statusCode: response.statusCode,
        message: message,
      );
    }
  }

  Future<T> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      throw NotificationServiceException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } on HttpException catch (e) {
      throw NotificationServiceException(
        statusCode: 0,
        message: 'HTTP Error: ${e.message}',
      );
    } on FormatException {
      throw NotificationServiceException(
        statusCode: 0,
        message: 'Invalid response format',
      );
    }
  }

  // Get All Notifications
  Future<List<NotificationModel>> getNotifications(String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse(_baseUrl),
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response) as List;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    });
  }

  // Get Unread Notifications
  Future<List<NotificationModel>> getUnreadNotifications(String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl/unread'),
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response) as List;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    });
  }

  // Get Unread Count
  Future<int> getUnreadCount(String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.get(
        Uri.parse('$_baseUrl/unread/count'),
        headers: _authHeaders(authToken),
      );

      final data = _handleResponse(response);
      return data['count'] as int;
    });
  }

  // Mark as Read
  Future<void> markAsRead(String notificationId, String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/$notificationId/read'),
        headers: _authHeaders(authToken),
      );

      _handleResponse(response);
    });
  }

  // Mark All as Read
  Future<void> markAllAsRead(String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/read-all'),
        headers: _authHeaders(authToken),
      );

      _handleResponse(response);
    });
  }

  // Delete Notification
  Future<void> deleteNotification(String notificationId, String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/$notificationId'),
        headers: _authHeaders(authToken),
      );

      _handleResponse(response);
    });
  }

  // Register FCM Token
  Future<void> registerFcmToken({
    required String token,
    required String deviceType,
    required String authToken,
  }) async {
    return _safeApiCall(() async {
      final response = await _client.post(
        Uri.parse('$_baseUrl/token'),
        headers: _authHeaders(authToken),
        body: json.encode({
          'token': token,
          'deviceType': deviceType,
        }),
      );

      _handleResponse(response);
    });
  }

  // Unregister FCM Token
  Future<void> unregisterFcmToken(String authToken) async {
    return _safeApiCall(() async {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/token'),
        headers: _authHeaders(authToken),
      );

      _handleResponse(response);
    });
  }

  void dispose() {
    _client.close();
  }
}

class NotificationServiceException implements Exception {
  final int statusCode;
  final String message;

  NotificationServiceException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'NotificationServiceException($statusCode): $message';
}

final notificationService = NotificationService();
