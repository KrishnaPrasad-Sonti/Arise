import 'dart:developer' as developer;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'notification_helper.dart';

class AlarmHelper {
  // Initialize alarms
  static Future<void> initializeAlarms() async {
    bool initialized = await AndroidAlarmManager.initialize();
    developer.log("Alarm Manager Initialized: $initialized", name: "AlarmHelper");
  }

  // Function triggered when alarm goes off
  static void alarmCallback() {
    developer.log("\u23F0 Alarm Triggered!", name: "AlarmHelper");
    NotificationHelper.showNotification(2, "Time’s Up!", "Your alarm just went off!");
  }

  // Function to schedule an alarm
  static Future<void> scheduleAlarm(DateTime alarmTime) async {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1)); // Schedule for the next day if time has passed
    }

    developer.log("Alarm set for: \$scheduledTime", name: "AlarmHelper");

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      0, // Unique alarm ID
      alarmCallback,
      exact: true,
      wakeup: true,
    );
  }
}