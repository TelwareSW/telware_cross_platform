import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.instance.setupFlutterNotifications();
  await PushNotificationService.instance.showNotification(message);
  print('Handling a background message ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  String? fcmToken;
  bool _isFlutterLocalNotificationsPluginConfigured = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();
    // Setup message handling
    await _setupMessageHandling();

    // Get FCM token

    try {
      fcmToken = await _messaging.getToken(
        vapidKey: dotenv.env['FIREBASE_VAPID_KEY'],
      );
      print('FCM token: $fcmToken');
    } catch (e) {
      print('Failed to get FCM token: $e');
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsPluginConfigured) return;

    // Android
    const channel = AndroidNotificationChannel(
      'telware_channel',
      'TelWare Channel',
      description: 'TelWare Channel Description',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
      AndroidInitializationSettings('icon/app_icon.png');

    _isFlutterLocalNotificationsPluginConfigured = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'telware_channel',
            'TelWare Channel',
            channelDescription: 'TelWare Channel Description',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'icon/app_icon.png',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandling() async {
    // Foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    // Background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Opened App
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  Future<void> _handleBackgroundMessage (RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
    if (message.data['type'] == 'chat') {
      // Go to chat screen
    } else if (message.data['type'] == 'call') {
      // Go to call screen
    }
  }
}