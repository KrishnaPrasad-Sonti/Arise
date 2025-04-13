import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class MoodStats extends StatefulWidget {
  final String userId;

  const MoodStats({super.key, required this.userId});

  @override
  State<MoodStats> createState() => _MoodStatsState();
}

class _MoodStatsState extends State<MoodStats> {
  DateTime? selectedDate;
  List<PieChartSectionData> chartSections = [];

  // Mood to Color Mapping
  final Map<String, Color> moodColors = {
     "overthinking": Colors.black,
    "jealousy": Colors.brown,
    "guilt": Colors.green,
    "sadness": Colors.tealAccent,
    "fear": Colors.purple,
    "anger": Colors.red
  };

  Future<void> getStatsOnDate(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, dynamic>> emotions = await getDailyEmotions(widget.userId, formattedDate);

    developer.log("Fetched emotions: $emotions");

    // Initialize all 24 hours as grey (default)
      Map<int, Color> hourColors = {for (int i = 0; i < 24; i++) i: Colors.grey};


    // Process emotions
    for (var entry in emotions) {
      String mood = entry['mood']?.toString().toLowerCase() ?? "";
      String timeString = entry['time'] ?? "00:00"; // Default to midnight if time is missing
      int hour = int.tryParse(timeString.split(":")[0]) ?? 0; // Extract hour

      if (mood.isNotEmpty) {
        hourColors[hour] = moodColors[mood] ?? Colors.grey; // Set mood color for that hour
      }
    }

    // Convert to PieChartSectionData
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < 24; i++) {
      sections.add(PieChartSectionData(
        value: 1, // Each section is equal in size
        title: "$i:00",
        color: hourColors[i],
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    setState(() {
      chartSections = sections;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Stats")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
                getStatsOnDate(picked);
              }
            },
            child: Text("Select Date"),
          ),
          if (chartSections.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PieChart(
                  PieChartData(
                    sections: chartSections,
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Fetch emotions from Firestore
Future<List<Map<String, dynamic>>> getDailyEmotions(String userId, String date) async {
  List<Map<String, dynamic>> moodEntries = [];

  try {
    CollectionReference entriesRef = FirebaseFirestore.instance
        .collection('mood_diary')
        .doc(userId)
        .collection('mood')
        .doc(date)
        .collection('entries');

    QuerySnapshot snapshot = await entriesRef.get();

    for (var doc in snapshot.docs) {
      moodEntries.add(doc.data() as Map<String, dynamic>);
    }
  } catch (e) {
    developer.log("Error fetching data: $e");
  }

  return moodEntries;
}
