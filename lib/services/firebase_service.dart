import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  late FirebaseMessaging _firebaseMessaging;
  final Logger _logger = Logger();

  FirebaseService() {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
      _logger.w('Firebase not initialized: $e');
    }
  }

  Future<void> initialize() async {
    try {
      // Request user permission for notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _logger.i('User granted provisional notification permission');
      } else {
        _logger
            .w('User declined or has not yet granted notification permission');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i(
            'Message received in foreground: ${message.notification?.title}');
        _handleMessage(message);
      });

      // Handle background message
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

      // Handle notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Notification tapped: ${message.notification?.title}');
        _handleNotificationTap(message);
      });

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      _logger.i('FCM Token: $token');
    } catch (e) {
      _logger.e('Firebase initialization error: $e');
    }
  }

  Future<String?> getToken() {
    return _firebaseMessaging.getToken();
  }

  void _handleMessage(RemoteMessage message) {
    // Handle message display in-app
    _logger.i('Title: ${message.notification?.title}');
    _logger.i('Body: ${message.notification?.body}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    final data = message.data;
    _logger.i('Notification data: $data');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    _logger.i('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    _logger.i('Unsubscribed from topic: $topic');
  }
}

Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
