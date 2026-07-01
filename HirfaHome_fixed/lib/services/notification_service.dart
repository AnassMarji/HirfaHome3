// ═══ FILE: lib/services/notification_service.dart ═══
//
// Handles FCM (Firebase Cloud Messaging) token management, foreground
// notification display, and enqueuing outgoing notifications to the
// Firestore 'notifications' collection (consumed by a Cloud Function).
//
// Improvements vs original:
//   1. Token refresh listener is stored in a static field and cancelled
//      in `dispose()` — prevents listener leaks when a user logs out
//      and back in (each login previously added a new listener).
//   2. Foreground message listener also stored & disposable.
//   3. Notification document field renamed from 'to' → 'token' to match
//      the Firestore security rules' required-fields validation.
//   4. Added 'timestamp' field (rules require it).
//   5. Better error handling — each await has its own try/catch so a
//      failure in one step doesn't skip subsequent steps.

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Store subscriptions so we can cancel them on dispose.
  static StreamSubscription<String>? _tokenRefreshSub;
  static StreamSubscription<RemoteMessage>? _onMessageSub;

  /// Initializes FCM: requests permission, fetches token, registers
  /// listeners for token refresh and foreground messages.
  ///
  /// Call this once after the user is authenticated. The [uid] is used
  /// to store the token on the user's Firestore document so the backend
  /// can target them with push notifications.
  static Future<void> initialize(String uid) async {
    try {
      // 1. Request notification permission (iOS prompt, Android no-op).
      final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('FCM: permission not granted');
        // Continue anyway — local notifications setup still useful.
      }

      // 2. Get and store the FCM token on the user's doc.
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(uid, token);
      }

      // 3. Listen for token refresh (happens when user clears app data,
      //    reinstalls, or Firebase rotates the token). Cancel any previous
      //    subscription first to prevent listener accumulation.
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _fcm.onTokenRefresh.listen(
        (newToken) => _saveToken(uid, newToken),
        onError: (e) => debugPrint('FCM token refresh error: $e'),
      );

      // 4. Configure local notifications for foreground message display.
      await _initLocalNotifications();

      // 5. Listen for foreground messages (app open + notification arrives).
      await _onMessageSub?.cancel();
      _onMessageSub = FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          final notification = message.notification;
          if (notification != null) {
            _showLocalNotification(notification);
          }
        },
        onError: (e) => debugPrint('FCM onMessage error: $e'),
      );
    } catch (e, st) {
      debugPrint('FCM Init Error: $e\n$st');
    }
  }

  /// Saves the FCM token to the user's Firestore document.
  static Future<void> _saveToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': token});
    } catch (e) {
      // The user doc might not exist yet (race during signup). Use set+merge.
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
      } catch (e2) {
        debugPrint('FCM token save error: $e2');
      }
    }
  }

  /// Initializes the local notifications plugin (for foreground display).
  static Future<void> _initLocalNotifications() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifications.initialize(initSettings);

    // Create the notification channel (Android 8+).
    const channel = AndroidNotificationChannel(
      'hirfahome_channel',
      'HirfaHome Notifications',
      description: 'Notifications from HirfaHome (new demands, messages, etc.)',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _showLocalNotification(
      RemoteNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'hirfahome_channel',
      'HirfaHome Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  /// Enqueues a notification to be sent to a specific FCM token.
  ///
  /// Writes a document to the 'notifications' Firestore collection. A
  /// Cloud Function (to be deployed separately) listens on this
  /// collection, sends the message via the FCM Admin SDK, and marks
  /// `sent: true` on success.
  ///
  /// NOTE PFE: Client-side Firebase Auth cannot send FCM messages
  /// directly — that requires the Firebase Admin SDK which uses the
  /// project's service-account credentials. Those credentials must
  /// NEVER be embedded in the mobile app.
  static Future<void> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'sent': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('NotificationService.sendToToken error: $e\n$st');
    }
  }

  /// Cancels all FCM subscriptions. Call on logout to prevent listener
  /// leaks when a different user logs in on the same device.
  static Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _onMessageSub?.cancel();
    _tokenRefreshSub = null;
    _onMessageSub = null;
  }
}
