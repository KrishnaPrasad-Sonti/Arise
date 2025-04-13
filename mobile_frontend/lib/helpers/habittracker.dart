import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HabitTrackerPage extends StatefulWidget {
  final String userId;

  const HabitTrackerPage({super.key, required this.userId});

  @override
  HabitTrackerPageState createState() => HabitTrackerPageState();
}

class HabitTrackerPageState extends State<HabitTrackerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> habits = [];
  Map<String, bool> habitStatus = {};
  TextEditingController habitController = TextEditingController();
  bool showAddHabit = false; // State to control visibility of TextField and button

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
  String userId = _auth.currentUser!.uid;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String yesterday = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 1)));

  DocumentSnapshot doc =
      await _firestore.collection('habbit-tracker').doc(userId).get();

  if (doc.exists) {
    Map<String, dynamic>? progress = doc.data() as Map<String, dynamic>?;
    List<String> habitsList = List<String>.from(progress?['habitsList'] ?? []);

    if (progress != null) {
      // Get today's progress if available
      if (progress.containsKey('progress.$today')) {
        setState(() {
          habitStatus = Map<String, bool>.from(
              (progress['progress.$today'] as Map<String, dynamic>)
                  .map((key, value) => MapEntry(key, value == 1)));
          habits = habitsList; // Ensure habits list is used
        });
      }
      // Get yesterday's progress if today's progress doesn't exist
      else if (progress.containsKey('progress.$yesterday')) {
        setState(() {
          habitStatus = Map<String, bool>.from(
              (progress['progress.$yesterday'] as Map<String, dynamic>)
                  .map((key, value) => MapEntry(key, value == 1)));
          habits = habitsList;
        });
      } 
      // If no progress for today or yesterday, initialize with all habits unchecked
      else {
        setState(() {
          habitStatus = {for (var habit in habitsList) habit: false};
          habits = habitsList;
        });
      }
    }
  }
}

  void _addHabit(String habit) {
    setState(() {
      if (!habits.contains(habit) && habit.isNotEmpty) {
        habits.add(habit);
        habitStatus[habit] = false;
      }
      showAddHabit = false; // Hide the TextField and button after adding
    });
    habitController.clear();
  }

  void _toggleHabit(String habit) {
    setState(() {
      habitStatus[habit] = !habitStatus[habit]!;
    });
  }

  void _saveHabits() async {
  String userId = _auth.currentUser!.uid;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Convert habitStatus to binary (0 or 1) to save in Firestore
  Map<String, dynamic> binaryData = {};
  habitStatus.forEach((key, value) {
    binaryData[key] = value ? 1 : 0;
  });

  // Store the habits list and the progress
  await _firestore.collection('habbit-tracker').doc(userId).set({
    'habitsList': habits,  // Store the list of all habits
    'progress.$today': binaryData,  // Store today's progress
  }, SetOptions(merge: true));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Progress saved successfully!'),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 38, 40, 56).withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.8),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '            HABIT TRACKER',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 175, 202, 202),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: const Color.fromARGB(255, 28, 134, 188)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(color: Colors.blue),
              ListView.builder(
                shrinkWrap: true,
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  String habit = habits[index];
                  return CheckboxListTile(
                    title: Text(
                      habit,
                      style: TextStyle(color: Colors.white),
                    ),
                    value: habitStatus[habit] ?? false,
                    activeColor: Colors.cyanAccent,
                    onChanged: (bool? value) {
                      _toggleHabit(habit);
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveHabits,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue),
                  ),
                ),
                child: Text(
                  'Save Progress',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              // Conditionally show the TextField and Add button
              if (showAddHabit) ...[
                TextField(
                  controller: habitController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter new habit',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 188, 214, 214)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _addHabit(habitController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                  child: Text(
                    'Add New Habit',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

 floatingActionButton: Stack(
  children: [
    Positioned(
      bottom: 180, // Adjust this value to move it higher
      right: 10,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            showAddHabit = !showAddHabit; // Toggle visibility
          });
        },
        backgroundColor:  Colors.blue,
        child: Icon(
          showAddHabit ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
    ),
  ],
),

    );
  }
}