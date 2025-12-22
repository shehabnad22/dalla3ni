import 'package:flutter/foundation.dart';

/// Notification Service for Push Notifications
/// Handles Firebase Cloud Messaging for background notifications
/// 
/// Setup Instructions:
/// 1. Add firebase_core and firebase_messaging to pubspec.yaml
/// 2. Configure Firebase project and download google-services.json
/// 3. Initialize Firebase in main.dart
/// 
/// Background notifications work even when app is closed

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // TODO: Uncomment when Firebase is configured
    /*
    await Firebase.initializeApp();
    
    // Request permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await messaging.getToken();
    debugPrint('FCM Token: $token');
    // TODO: Send token to backend

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification tap when app was terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    */

    _initialized = true;
    if (kDebugMode) {
      debugPrint('NotificationService initialized');
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(dynamic message) {
    if (kDebugMode) {
      debugPrint('Foreground message: ${message.data}');
    }
    
    // Show local notification or dialog
    final data = message.data;
    if (data['type'] == 'new_order') {
      // Show incoming order dialog
      _showIncomingOrderNotification(data);
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(dynamic message) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${message.data}');
    }
    
    final data = message.data;
    if (data['type'] == 'new_order') {
      // Navigate to order details
    }
  }

  /// Show incoming order notification
  void _showIncomingOrderNotification(Map<String, dynamic> data) {
    // TODO: Show local notification with sound
    // Use flutter_local_notifications package
    if (kDebugMode) {
      debugPrint('New order notification: $data');
    }
  }

  /// Subscribe to driver topic for targeted notifications
  Future<void> subscribeToDriverTopic(String driverId) async {
    // TODO: FirebaseMessaging.instance.subscribeToTopic('driver_$driverId');
    if (kDebugMode) {
      debugPrint('Subscribed to driver topic: $driverId');
    }
  }

  /// Unsubscribe from driver topic
  Future<void> unsubscribeFromDriverTopic(String driverId) async {
    // TODO: FirebaseMessaging.instance.unsubscribeFromTopic('driver_$driverId');
    if (kDebugMode) {
      debugPrint('Unsubscribed from driver topic: $driverId');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(dynamic message) async {
  if (kDebugMode) {
    debugPrint('Background message: ${message.data}');
  }
  
  // Handle background notification
  // This runs even when app is closed
  final data = message.data;
  if (data['type'] == 'new_order') {
    // Store notification for later processing
    // Show system notification with sound
  }
}

