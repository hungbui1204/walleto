import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class LocalNotificationService with LogMixin {
  const LocalNotificationService();

  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'Default';
  static const _channelName = 'Default';
  static const _channelDescription = 'Default Channel';
  static const _androidDefaultIcon = '@drawable/notification_icon';

  static Future<void> init() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(_androidDefaultIcon),
      iOS: DarwinInitializationSettings(),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final json = jsonDecode(details.payload!);
          final message = RemoteMessage(data: json);

          /// Waiting for app to initialize
          Future.delayed(const Duration(milliseconds: 500), () => handleNavigate(message: message));
        }
      },
    );

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
  }

  static void handleNavigate({RemoteMessage? message}) {
    if (message != null) {
      // TODO: Implement navigation logic based on the message data
    }
  }

  static Future<void> notify(RemoteMessage message) async {
    FlutterAppBadge.count(message.notification?.android?.count ?? 0);

    final androidNotificationDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      colorized: true,
      color: Colors.white,
      priority: Priority.high,
      importance: Importance.max,
      channelDescription: _channelDescription,
      number: message.notification?.android?.count,
    );
    final iOSNotificationDetails = DarwinNotificationDetails(
      badgeNumber: message.notification?.android?.count,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await FlutterLocalNotificationsPlugin().show(
      id,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }
}
