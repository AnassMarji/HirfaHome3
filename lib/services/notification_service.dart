
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // AJOUT : Initialisation et stockage du token FCM (Section 8)
  static Future<void> initialize(String uid) async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _fcm.getToken();
        if (token != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'fcmToken': token,
          });
        }

        // Écouter le rafraîchissement du token FCM et le mettre à jour
        _fcm.onTokenRefresh.listen((newToken) {
          FirebaseFirestore.instance.collection('users').doc(uid).update({
            'fcmToken': newToken,
          });
        });
      }

      // Configuration des notifications locales pour le premier plan (Foreground)
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      
      await _localNotifications.initialize(initSettings);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        if (notification != null) {
          _showLocalNotification(notification);
        }
      });
    } catch (e) {
      debugPrint('FCM Init Error: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hirfahome_channel',
      'HirfaHome Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  /// Envoie une notification push vers un token FCM spécifique.
  ///
  /// Comme l'envoi direct depuis le client Flutter nécessite des
  /// credentials serveur (clé privée du compte de service), on écrit
  /// dans une collection Firestore 'notifications' qui sera traitée
  /// par une Cloud Function ou un serveur backend.
  ///
  /// Document créé :
  ///   { to, title, body, sent: false, createdAt: serverTimestamp }
  ///
  /// NOTE PFE : Une Cloud Function `onDocumentCreated` sur
  /// 'notifications/{docId}' doit lire ce document, envoyer le
  /// message via l'Admin SDK FCM, puis marquer `sent: true`.
  static Future<void> sendToToken({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'to': token,
        'title': title,
        'body': body,
        'sent': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService.sendToToken error: $e');
    }
  }
}