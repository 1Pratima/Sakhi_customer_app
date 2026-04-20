import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:logger/logger.dart';
import 'package:com.navajyoti.app/services/api_service.dart';

class FirebaseService {
  late FirebaseMessaging _firebaseMessaging;
  final fln.FlutterLocalNotificationsPlugin _localNotifications =
      fln.FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  ApiService? _apiService;

  FirebaseService() {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
      _logger.w('Firebase not initialized: $e');
    }
  }

  void setApiService(ApiService apiService) {
    _apiService = apiService;
  }

  Future<void> initialize() async {
    try {
      // 1. Initialize Local Notifications
      const fln.AndroidInitializationSettings initializationSettingsAndroid =
          fln.AndroidInitializationSettings('@mipmap/ic_launcher');
      const fln.DarwinInitializationSettings initializationSettingsIOS =
          fln.DarwinInitializationSettings();
      const fln.InitializationSettings initializationSettings = fln.InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (fln.NotificationResponse details) {
          _handleNotificationResponse(details);
        },
      );

      // Create high importance channel for Android
      const fln.AndroidNotificationChannel channel = fln.AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: fln.Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 2. Request user permission for notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted notification permission');
      }

      // 3. Handle messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Message received in foreground: ${message.notification?.title}');
        _showLocalNotification(message);
        _handleMessage(message);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Notification tapped: ${message.notification?.title}');
        _handleNotificationTap(message);
      });

      // 4. Initial Token registration
      await registerDevice();
      
      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token refreshed: $newToken');
        _apiService?.registerDeviceToken(
          clientId: 'guest',
          appUserId: '0',
          fcmToken: newToken,
          deviceId: 'unknown_device',
        );
      });

    } catch (e) {
      _logger.e('Firebase initialization error: $e');
    }
  }

  Future<void> registerDevice({
    String? clientId,
    String? appUserId,
    String? deviceId,
  }) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && _apiService != null) {
        _logger.i('Registering FCM Token: $token');
        await _apiService!.registerDeviceToken(
          clientId: clientId ?? 'guest',
          appUserId: appUserId ?? '0',
          fcmToken: token,
          deviceId: deviceId ?? 'unknown_device',
        );
      }
    } catch (e) {
      _logger.w('Could not register device token: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: fln.DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationResponse(fln.NotificationResponse details) {
    _logger.i('Local Notification tapped: ${details.payload}');
    // Logic for navigation based on payload
  }

  void _handleMessage(RemoteMessage message) {
    // Logic to update UI reactively if needed
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Deep linking logic
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

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
