import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Notifier so the UI can react to new messages
  final ValueNotifier<RemoteMessage?> messageNotifier =
      ValueNotifier<RemoteMessage?>(null);

  /// Call once from HomeScreen.initState()
  Future<void> initialize() async {
    await _requestPermission();
    await _setupFCMHandlers();
    // On Android, FCM won't show heads-up notifications in foreground
    // unless we set the foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─── Permission ──────────────────────────────────────────────────────────

  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  // ─── FCM Handlers ────────────────────────────────────────────────────────

  Future<void> _setupFCMHandlers() async {
    // 1. Foreground messages - UI will show popup dialog via messageNotifier
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      messageNotifier.value = message;
    });

    // 2. App opened from background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped (background): ${message.notification?.title}');
      messageNotifier.value = message;
    });

    // 3. App opened from terminated state
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated: ${initialMessage.notification?.title}');
      messageNotifier.value = initialMessage;
    }

    // 4. Background handler
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  // ─── Token ───────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    if (Platform.isIOS) {
      await _messaging.getAPNSToken();
    }
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    return token;
  }
}

// Must be top-level function
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}