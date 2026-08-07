import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelIdSwaps = 'skillnearby_swaps';
  static const String channelNameSwaps = 'Skill Swap Requests';

  static const String channelIdMessages = 'skillnearby_messages';
  static const String channelNameMessages = 'Chat Messages & Proposals';

  Future<void> initialize({void Function(String? payload)? onSelectNotification}) async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (onSelectNotification != null) {
          onSelectNotification(response.payload);
        }
      },
    );

    _isInitialized = true;
  }

  Future<void> showSwapRequestNotification({
    required String senderName,
    required String skillOffered,
    required String requestId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelIdSwaps,
      channelNameSwaps,
      channelDescription: 'Alerts when a neighbour requests a skill swap with you',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      requestId.hashCode,
      '🤝 New Swap Request from $senderName',
      '$senderName offers $skillOffered. Tap to review details.',
      details,
      payload: '/requests',
    );
  }

  Future<void> showChatMessageNotification({
    required String senderName,
    required String messageText,
    required String profileId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelIdMessages,
      channelNameMessages,
      channelDescription: 'Alerts when a neighbour sends a message or swap proposal',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      profileId.hashCode,
      '💬 $senderName',
      messageText,
      details,
      payload: '/chat/$profileId',
    );
  }

  Future<void> showSwapAcceptedNotification({
    required String neighbourName,
    required String skillOffered,
    required String requestId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelIdSwaps,
      channelNameSwaps,
      channelDescription: 'Alerts when a neighbour accepts your skill swap request',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      requestId.hashCode.abs(),
      '🎉 Swap Request Accepted!',
      '$neighbourName accepted your swap for $skillOffered. Tap to chat!',
      details,
      payload: '/requests',
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});
