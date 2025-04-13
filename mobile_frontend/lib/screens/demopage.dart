import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ✅ Initialize Notifications
Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
  debugPrint("🌍 Current Timezone: $currentTimeZone");

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  bool? granted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  if (granted ?? false) {
    debugPrint("✅ Notification permission granted.");
  } else {
    debugPrint("❌ Notification permission denied.");
  }

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  debugPrint("✅ Notifications Initialized Successfully.");
}

// ✅ Function to Show an Immediate Test Notification
Future<void> showTestNotification() async {
  debugPrint("🔔 Showing test notification...");
  await flutterLocalNotificationsPlugin.show(
    0,
    "🔔 Test Notification",
    "This is a test notification!",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
  debugPrint("✅ Test notification should appear now.");
}

// ✅ Function to Schedule a Debugging Notification
Future<void> scheduleDebugNotification() async {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  final tz.TZDateTime scheduledTime = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day + 1, // Move to the next day
    5, // 6 AM
    0, // 0 minutes
  );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    "📅 Scheduled Reminder",
    "This is a scheduled notification test.",
    scheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminders',
        importance: Importance.max,
        priority: Priority.high,

       
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  debugPrint("✅ Notification Scheduled Successfully.");
}


// ✅ Callable Page
class demopage extends StatefulWidget {
  @override
  _DemopageState createState() => _DemopageState();
}

class _DemopageState extends State<demopage> {
  @override
  void initState() {
    super.initState();
    initializeNotifications(); // Initialize notifications when page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Debugger")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: showTestNotification,
              child: const Text("🔔 Show Test Notification"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: scheduleDebugNotification,
              child: const Text("⏳ Schedule Notification (5 sec)"),
            ),
          ],
        ),
      ),
    );
  }
}
