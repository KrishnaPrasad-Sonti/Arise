import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Taskremainderhelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


  // Processes a reminder and stores it in Firestore under `entries`
  static Future<void> processReminder(String userId, String dateKey, String title, String? time) async {
    if (userId.isEmpty) {
      debugPrint(" Error: User ID is empty");
      return;
    }

    try {
      DocumentReference docRef = _firestore
          .collection("user_reminders") // Collection for all users
          .doc(userId) // Each user has their own document
          .collection("remainders") // Ensure correct path
          .doc(dateKey);

      debugPrint(" Firestore Path: user_reminders/$userId/entries/$dateKey");

      // First, get current timestamp
      Timestamp createdAt = Timestamp.now();

      // Save reminder without timestamp inside arrayUnion
      await docRef.set({
        "tasks": FieldValue.arrayUnion([
          {
            "title": title,
            "time": time ?? "All Day",
          }
        ]),
        "lastUpdated": createdAt // Store timestamp separately
      }, SetOptions(merge: true));

      debugPrint(" Reminder saved successfully for user: $userId on $dateKey");
    } catch (e) {
      debugPrint("Firestore error: $e");
    }
  }



}
