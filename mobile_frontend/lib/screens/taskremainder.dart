import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class Taskreminder extends StatefulWidget {
  final String userId;
  const Taskreminder({super.key, required this.userId});

  @override
  TaskReminderState createState() => TaskReminderState();
}

class TaskReminderState extends State<Taskreminder> {
  DateTime selectedDate = DateTime.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Stream<List<Map<String, dynamic>>> _getReminders() {
    return firestore
        .collection("user_reminders")
        .doc(widget.userId)
        .collection("remainders")
        .doc(getFormattedDate(selectedDate))
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      return List<Map<String, dynamic>>.from(snapshot.data()?["tasks"] ?? []);
    });
  }

  void _addReminderDialog() {
    TextEditingController titleController = TextEditingController();
    bool isAllDay = false;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Add Reminder"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: "Enter reminder title"),
                  ),
                  CheckboxListTile(
                    title: Text("All Day"),
                    value: isAllDay,
                    onChanged: (value) {
                      setDialogState(() => isAllDay = value ?? false);
                    },
                  ),
                  if (!isAllDay)
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setDialogState(() => selectedTime = pickedTime);
                        }
                      },
                      child: Text(
                        selectedTime == null
                            ? "Pick Time"
                            : "Selected: ${selectedTime!.format(context)}",
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      _saveReminder(titleController.text, isAllDay, selectedTime);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveReminder(String title, bool isAllDay, TimeOfDay? selectedTime) async {
    String formattedDate = getFormattedDate(selectedDate);
    String formattedTime = isAllDay
        ? "All Day"
        : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

    DocumentReference dateDoc = firestore
        .collection("user_reminders")
        .doc(widget.userId)
        .collection("remainders")
        .doc(formattedDate);

    await dateDoc.get().then((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        List<dynamic> existingReminders = List.from(data["reminders"] ?? []);
        existingReminders.add({"time": formattedTime, "title": title});

        dateDoc.set({
            "tasks": FieldValue.arrayUnion([{"time": formattedTime, "title": title} ]) }, 
             SetOptions(merge: true));

           }
           
       else {
        dateDoc.set({
          "tasks": [
            {"time": formattedTime, "title": title}
          ]
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
  focusedDay: selectedDate,
  firstDay: DateTime(2020),
  lastDay: DateTime(2100),
  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
  onDaySelected: (selectedDay, _) {
    setState(() => selectedDate = selectedDay);
  },
  availableCalendarFormats: { CalendarFormat.month: 'Month' }, // Only Month View

  // ✅ 1. Center the month name & style header row
  headerStyle: HeaderStyle(
    formatButtonVisible: false, // Hide "2 Weeks" / "Month" toggle
    titleCentered: true, // Center month name
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0)),
    leftChevronIcon: Icon(Icons.chevron_left, color: const Color.fromARGB(255, 0, 0, 0)), // Style icons
    rightChevronIcon: Icon(Icons.chevron_right, color: const Color.fromARGB(255, 1, 0, 0)),
    
  ),

  //  2. Set calendar background color
  calendarStyle: CalendarStyle(
    outsideDaysVisible: false, // Hide other month dates
    todayDecoration: BoxDecoration( // Highlight Today
      color: const Color.fromARGB(255, 42, 158, 96),
      shape: BoxShape.circle,
    ),
    selectedDecoration: BoxDecoration( // Highlight Selected Date
      color: const Color.fromARGB(255,80,0,115),
      shape: BoxShape.circle,
    ),
    defaultTextStyle: TextStyle(color: Colors.black), // Default text color
    weekendTextStyle: TextStyle(color: Colors.red), // Style weekends
  ),

  //  3. Style the days of the week
  daysOfWeekStyle: DaysOfWeekStyle(
    weekendStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
  ),
),

            SizedBox(height: 30), // Added space below the calendar
            Container(
              color: const Color.fromARGB(255, 169, 115, 175),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "         Notifications on this day ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getReminders(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            "No reminders for this day.",
                            style: TextStyle(color: const Color.fromARGB(255, 238, 237, 237)),
                          ),
                        );
                      }

                      var reminders = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(2, 3),
                                ),
                              ],
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              title: Text(
                                reminders[index]["title"] ?? "No Title",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Time: ${reminders[index]["time"] ?? "Not set"}",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: selectedDate.isBefore(DateTime.now().subtract(Duration(days: 1)))
    ? null
    : FloatingActionButton(
        onPressed: _addReminderDialog,
        child: Icon(Icons.add),
      ),

    );
  }
}
