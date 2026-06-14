import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../utils/logger.dart';
import './app_shell_service.dart';

/// Handles Firebase Cloud Messaging (FCM) for push notifications.
///
/// Shows notifications when:
/// - App is CLOSED → Shows status bar notification
/// - App is OPEN → Shows toast at top right + stores in DB
class FirebaseMessagingService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static VoidCallback? _onNotificationReceived;

  /// Initialize FCM and set up listeners
  static Future<void> initialize({
    VoidCallback? onNotificationReceived,
  }) async {
    if (_initialized) return;
    _initialized = true;
    _onNotificationReceived = onNotificationReceived;

    try {
      AppLogger.i('Starting FCM initialization', tag: 'FCM');

      // Request permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      AppLogger.i('FCM permissions requested: $settings', tag: 'FCM');

      // Get FCM token
      final token = await _fcm.getToken();
      AppLogger.i('FCM Token: $token', tag: 'FCM');

      if (token == null) {
        AppLogger.e('FCM token is NULL - check Google Play Services', tag: 'FCM');
      }

      // Handle foreground messages (app is OPEN)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      AppLogger.i('FCM foreground listener registered', tag: 'FCM');

      // Handle background message (app is TERMINATED)
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      AppLogger.i('FCM background listener registered', tag: 'FCM');

      // Handle notification tap (app is CLOSED or in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      AppLogger.i('FCM initialization complete', tag: 'FCM');
    } catch (e) {
      AppLogger.e('FCM initialization error: $e', tag: 'FCM');
    }
  }

  /// Get FCM token for this device
  static Future<String?> getToken() => _fcm.getToken();

  /// Handle message when app is in FOREGROUND
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.i('Foreground message received', tag: 'FCM');

    final notification = message.notification;
    if (notification != null) {
      // Show toast/notification
      _showNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        data: message.data,
      );

      // Notify listeners to refresh notifications page
      _onNotificationReceived?.call();
    }
  }

  /// Handle message when app is CLOSED
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    AppLogger.i('Background message received', tag: 'FCM');
    // Firebase automatically shows notification when app is closed
    // No need to do anything here
  }

  /// Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    AppLogger.i('Notification tapped', tag: 'FCM');
    // Default behavior: navigate to alerts page if no URL provided
    final url = message.data['url'];
    if (url == null || url.isEmpty) {
      // No URL provided, navigate to alerts/notifications page
      switchToTab('alerts');
    }
    // If URL is provided, it should be handled by the app's navigation logic
  }

  /// Show local notification
  static Future<void> _showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // Initialize local notifications if not done
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'notifications',
            'App Notifications',
            description: 'Push notifications from healthcare app',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

    // Show notification
    await _localNotifications.show(
      DateTime.now().hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'notifications',
          'App Notifications',
          channelDescription: 'Push notifications from healthcare app',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data.toString(),
    );

    AppLogger.i('Notification shown: $title', tag: 'FCM');
  }
}
