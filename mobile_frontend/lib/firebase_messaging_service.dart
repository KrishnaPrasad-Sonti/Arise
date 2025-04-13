import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer'; // For logging

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log(" Background Message Received: ${message.messageId}");
}

class FirebaseMessagingService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    log("Initializing Firebase Messaging Service...");

    // Request Notification Permissions
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log(" User granted permission for notifications.");
    } else {
      log(" User denied notifications.");
      return; // Stop if the user denies permissions
    }

    // Retrieve and log the FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    log(" FCM Token: $token");

    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        log(" Notification Clicked: ${response.payload}");
      },
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse response) async {
        log(" Background Notification Clicked: ${response.payload}");
      },
    );

    // Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log(" Foreground Message: ${message.notification?.title}");
      if (message.notification != null) {
        await showNotification(message.notification!.title, message.notification!.body);
      }
    });

    // Handle when the app is opened by tapping on a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(" Notification Opened: ${message.data}");
    });
  }

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> showNotification(String? title, String? body) async {
    if (title == null || body == null) return;

    var androidDetails = const AndroidNotificationDetails(
      'channelId', 'channelName',
      importance: Importance.high,
      priority: Priority.high,
    );

    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, title, body, generalNotificationDetails,
    );
  }
}
