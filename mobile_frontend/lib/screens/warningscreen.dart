import 'package:flutter/material.dart';

class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Dark futuristic background
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 3), // Glowing border
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 191, 255, 0.7),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.blueGrey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "⚠️ QUEST INFO",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "[Daily Quest: Strength Training has arrived!]",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Divider(color: Colors.blueAccent),
              const SizedBox(height: 8),
              const Text(
                "GOAL",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              questProgress("Push-ups", "100/100"),
              questProgress("Sit-ups", "100/100"),
              questProgress("Squats", "100/100"),
              questProgress("Running", "10/10 km"),
              const SizedBox(height: 16),
              const Text(
                "⚠️ WARNING: Failure to complete\nthis quest will result in an appropriate **penalty**.",
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Icon(Icons.check_box, color: Colors.greenAccent, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget questProgress(String title, String progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        Text(progress, style: const TextStyle(color: Colors.greenAccent)),
      ],
    );
  }
}
