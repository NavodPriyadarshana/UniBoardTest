import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────
// BACKGROUND MESSAGE HANDLER
// Must be top level function
// ─────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

// ─────────────────────────────────────────────
// NOTIFICATION SERVICE
// Handles FCM push notifications
// ─────────────────────────────────────────────
class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ── High importance notification channel ──
  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications',
    importance: Importance.high,
  );

  // ─────────────────────────────────────────────
  // INITIALISE
  // ─────────────────────────────────────────────
  Future<void> initialise() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    // Create notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Save FCM token to Firestore
    await _saveTokenToFirestore();

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _updateTokenInFirestore(newToken);
    });
  }

  // ─────────────────────────────────────────────
  // SHOW LOCAL NOTIFICATION
  // Shows notification when app is in foreground
  // ─────────────────────────────────────────────
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SAVE TOKEN TO FIRESTORE
  // Saves device FCM token for sending notifications
  // ─────────────────────────────────────────────
  Future<void> _saveTokenToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await _fcm.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});

      print('FCM Token saved: $token');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE TOKEN IN FIRESTORE
  // Updates token when it refreshes
  // ─────────────────────────────────────────────
  Future<void> _updateTokenInFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SEND NOTIFICATION
  // Sends notification to a specific user
  // via their FCM token saved in Firestore
  // ─────────────────────────────────────────────
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      // Get user FCM token from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final token = userDoc.data()?['fcmToken'];
      if (token == null) return;

      // Save notification to Firestore
      // Firebase Cloud Function will handle
      // sending via FCM
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'token': token,
        'title': title,
        'body': body,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      print('Notification queued for user: $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}