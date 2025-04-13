import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotification() async {
    try {
      await _firebaseMessaging.requestPermission();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle when user taps the notification
      });

      print("Fetching FCM token...");
      await _getFcmToken();
      print("Initializing local notifications...");
      await _initializeLocalNotification();
      print("Notification initialization completed.");
    } catch (e) {
      print("Error in Notification Initialization: $e");
    }
  }

  static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  static Future<void> _initializeLocalNotification() async {
    AndroidInitializationSettings androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
    print("Local notifications initialized.");
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification == null) {
      print("Received a message but it has no notification payload.");
      return;
    }

    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'CHANNEL_ID', 'CHANNEL_NAME',
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      notification.title ?? "No Title",
      notification.body ?? "No Body",
      details,
    );

    print("Foreground notification displayed.");
  }
}
