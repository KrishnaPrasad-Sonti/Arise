import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'dart:math';

class StatsPage extends StatefulWidget {
  final String userId;

  const StatsPage({super.key, required this.userId});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<String> habits = [];
  String? selectedHabit;
  Map<String, Map<DateTime, bool>> habitProgress = {};
  Map<String, Color> habitColors = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  Future<void> _loadHabits() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('habbit-tracker')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        var data = doc.data();
        if (data is Map) {
          Map<String, dynamic> safeData =
              data.map((key, value) => MapEntry(key.toString(), value));

          List<String> habitsList =
              (safeData['habitsList'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];

          Map<String, Map<DateTime, bool>> habitData = {};
          Map<String, Color> colors = {};

          for (var habit in habitsList) {
            habitData[habit] = {};
            colors[habit] = _generateRandomColor();
          }

          safeData.forEach((key, value) {
            if (key.startsWith('progress.') && value is Map) {
              String dateKey = key.replaceFirst('progress.', '');
              try {
                DateTime parsedDate =
                    DateTime.parse(dateKey).toLocal();
                parsedDate = DateTime(
                    parsedDate.year, parsedDate.month, parsedDate.day);
                (value as Map<dynamic, dynamic>).forEach((habit, status) {
                  if (habitsList.contains(habit.toString())) {
                    bool statusBool = status == 1;
                    habitData[habit.toString()]![parsedDate] = statusBool;
                  }
                });
              } catch (_) {}
            }
          });

          setState(() {
            habits = habitsList;
            habitProgress = habitData;
            habitColors = colors;
            selectedHabit = habitsList.isNotEmpty ? habitsList.first : null;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Invalid data format from Firestore';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          habits = [];
          selectedHabit = null;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load habits: $e';
      });
    }
  }

  Map<DateTime, int> _generateHeatmapData() {
    Map<DateTime, int> dataSet = {};
    if (selectedHabit != null && habitProgress[selectedHabit] != null) {
      habitProgress[selectedHabit]!.forEach((date, status) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        if (status) {
          dataSet[normalizedDate] = 1;
        }
      });
    }
    return dataSet;
  }

  @override
  Widget build(BuildContext context) {
    Color? baseColor = selectedHabit != null ? habitColors[selectedHabit] : null;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF9013FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Stats of habits , mood',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : errorMessage != null
                  ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12.0, left: 90),
                          child: Text(
                            "Habit Progress",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 221, 219, 219),
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<String>(
                                value: selectedHabit,
                                hint: const Text("Select Habit", style: TextStyle(color: Color.fromARGB(255, 218, 208, 208))),
                                isExpanded: true,
                                onChanged: habits.isEmpty
                                    ? null
                                    : (String? newHabit) {
                                        setState(() {
                                          selectedHabit = newHabit;
                                        });
                                      },
                                items: habits.map((String habit) {
                                  return DropdownMenuItem<String>(
                                    value: habit,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          color: habitColors[habit] ?? Colors.grey,
                                          margin: const EdgeInsets.only(right: 8),
                                        ),
                                        Text(habit, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: const Color.fromARGB(255, 143, 142, 142),
                                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0),fontSize: 24),
                              ),
                              const SizedBox(height: 20),
                              if (selectedHabit != null && habitProgress[selectedHabit] != null)
                                SizedBox(
                                  height: 300,
                                  child: HeatMapCalendar(
                                    datasets: _generateHeatmapData(),
                                    colorMode: ColorMode.color,
                                    defaultColor: Colors.transparent,
                                    colorsets: {
                                      1: baseColor ?? Colors.blue,
                                    },
                                    initDate: DateTime(2025, 4, 1),
                                    flexible: true,
                                    showColorTip: false,
                                    size: 30.0,
                                    borderRadius: 4.0,
                                    textColor: const Color.fromARGB(255, 0, 0, 0),
                                    margin: const EdgeInsets.all(2.0),
                                  ),
                                ),
                              if (selectedHabit != null && _generateHeatmapData().isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Center(
                                    child: Text(
                                      "No progress data available for the selected habit.",
                                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (selectedHabit == null && habits.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Habit Colors:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: habits.map((habit) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          color: habitColors[habit] ?? Colors.grey,
                                          margin: const EdgeInsets.only(right: 4),
                                        ),
                                        Text(habit, style: const TextStyle(color: Colors.white)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                const Center(
                                  child: Text(
                                    "Please select a habit to view its detailed progress.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (habits.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                "No habits tracked yet. Add some to get started!",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}
