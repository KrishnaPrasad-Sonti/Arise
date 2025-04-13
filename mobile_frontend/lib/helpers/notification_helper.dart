import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';


class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🔹 Initialize local notifications
  static Future<void> initializeLocalNotifications() async {
    tz.initializeTimeZones();
    
    // Get local timezone dynamically
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint("🌎 Timezone Set: $currentTimeZone");
    } catch (e) {
      debugPrint("❌ Failed to get timezone: $e");
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // 🔹 Create Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminders',
      description: 'This channel is used for daily reminders',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint(" Notification Channel Created");

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      bool? granted = await androidImplementation.requestNotificationsPermission();
      if (granted ?? false) {
        debugPrint("✅ Notification Permission Granted");
      } else {
        debugPrint("🚫Notification Permission Denied");
      }
    }
  }

  // 🔹 Background message handler
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    developer.log("Handling background message: ${message.messageId}");
    showNotification(message.notification?.title, message.notification?.body);
  }

  // 🔹 Show local notification
  static void showNotification(String? title, String? body) async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
    );

    var generalNotificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? "Reminder",
      body ?? "You have a new reminder!",
      generalNotificationDetails,
    );
  }

  // 🔹 Schedule daily reminders
      
      static Future<void> scheduleTomorrowReminders(String? userId) async {
  if (userId == null) {
    debugPrint("❌ UserID is null");
    return;
  }
  debugPrint("⏳ Fetching tomorrow's reminders...");

  DateTime now = DateTime.now();
  String tomorrowKey = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 1)));

  // 🔹 Set notification for today at 6 PM
  DateTime notificationTime = DateTime(now.year, now.month, now.day, 16, 50);
  if (notificationTime.isBefore(now)) {
    notificationTime = notificationTime.add(const Duration(days: 1));
  }
  tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

  try {
    DocumentSnapshot tomorrowDoc = await FirebaseFirestore.instance
        .collection("user_reminders")
        .doc(userId)
        .collection("remainders")
        .doc(tomorrowKey)
        .get();

    if (!tomorrowDoc.exists) {
      debugPrint(" No reminders for tomorrow ($tomorrowKey).");
      return;
    }

    List<dynamic> reminders = tomorrowDoc["tasks"] ?? [];
    if (reminders.isEmpty) {
      debugPrint("📭 No tasks found for tomorrow.");
      return;
    }

    debugPrint("📜 Reminders for $tomorrowKey:");
    for (var task in reminders) {
      debugPrint("📝 Task: ${task['title']}, Time: ${task['time'] ?? 'All Day'}");
    }

    String notificationBody = reminders
        .map((task) => "• ${task['title']} at ${task['time'] ?? 'All Day'}")
        .join("\n");

    var androidDetails = const AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Unique ID
      "📅 Tomorrow's Reminders",
      notificationBody,
      tzScheduledTime,
      generalNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Ensures it triggers at 6 PM
    );

    debugPrint(" Reminder scheduled for tomorrow's tasks at ${tzScheduledTime.toLocal()}.");
  } catch (e) {
    debugPrint("Error fetching reminders: $e");
  }
}


  // 🔹 Cancel all notifications (Faculty Code)
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("❌ All notifications canceled.");
  }
}
