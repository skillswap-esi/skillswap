import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';

/// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
}

/// FCM Service for push notifications
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS and Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      
      // Get the token
      await _getToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Handle when app is opened from a notification
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
      await _getToken();
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Save token to backend if user is authenticated
      if (_fcmToken != null && authService.value.userProfile != null) {
        await authService.value.saveFcmToken(_fcmToken!);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) async {
    debugPrint('FCM Token refreshed: $token');
    _fcmToken = token;

    // Save new token to backend if user is authenticated
    if (authService.value.userProfile != null) {
      await authService.value.saveFcmToken(token);
    }
  }

  /// Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // You can show a local notification here using flutter_local_notifications
    // or display an in-app snackbar/dialog
    _showInAppNotification(message);
  }

  /// Handle when app is opened from a notification
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.messageId}');
    _handleNotificationTap(message);
  }

  /// Handle notification tap - navigate to appropriate screen
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    debugPrint('Handling notification tap with data: $data');

    // Handle different notification types
    final type = data['type'];
    switch (type) {
      case 'mission_request':
        // Navigate to mission detail page
        final missionId = data['missionId'];
        debugPrint('Navigate to mission: $missionId');
        // TODO: Add navigation logic
        break;
      case 'mission_accepted':
        final missionId = data['missionId'];
        debugPrint('Mission accepted: $missionId');
        // TODO: Add navigation logic
        break;
      case 'chat_message':
        final chatId = data['chatId'];
        debugPrint('Navigate to chat: $chatId');
        // TODO: Add navigation logic
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Show in-app notification (you can customize this)
  void _showInAppNotification(RemoteMessage message) {
    // This is a simple implementation
    // For a better UX, consider using flutter_local_notifications
    // or a custom overlay widget
    debugPrint('=== In-App Notification ===');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}

/// Global FCM service instance
final fcmService = FcmService();
