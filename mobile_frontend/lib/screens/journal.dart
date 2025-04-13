import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class JournalPage extends StatefulWidget {
 final String userId;

  const JournalPage({super.key, required this.userId});

  @override
  JournalPageState createState() => JournalPageState();
}

class JournalPageState extends State<JournalPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final  TextEditingController _journalController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _hasEntry = false;
  bool _isEditing = false;
  bool _showTextField = false;

  @override
  void initState() {
    super.initState();
    _loadJournalEntry();
  }

  void _loadJournalEntry() async {
  String dateKey = _selectedDay.toString().split(' ')[0];

  DocumentSnapshot snapshot = await _firestore
      .collection("journals")
      .doc(widget.userId) // Store based on user ID
      .collection("entries")
      .doc(dateKey)
      .get();

  setState(() {
    if (snapshot.exists) {
      _journalController.text = snapshot["entry"];
      _hasEntry = true;
      _showTextField = false;
    } else {
      _journalController.text = "";
      _hasEntry = false;
      _showTextField = false;
    }
    _isEditing = false;
  });
}

     
void _saveJournalEntry() async {
  String dateKey = _selectedDay.toString().split(' ')[0];
  String entry = _journalController.text.trim();

  if (entry.isNotEmpty) {
    await _firestore
        .collection("journals")
        .doc(widget.userId) // Store based on user ID
        .collection("entries")
        .doc(dateKey)
        .set({
      "entry": entry,
      "timestamp": FieldValue.serverTimestamp(),
    });

    setState(() {
      _hasEntry = true;
      _isEditing = false;
      _showTextField = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Journal saved!")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    bool isToday = isSameDay(_selectedDay, DateTime.now());
    bool isPastDate = _selectedDay.isBefore(DateTime.now()) && !isToday;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              "Arise Journal",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "MinervaModern",
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 50),

            // Calendar
            TableCalendar(
              
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadJournalEntry();
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
               calendarFormat: CalendarFormat.month,

            
              headerStyle: HeaderStyle(
                
                formatButtonVisible: false, // Hide format toggle button
                titleCentered: true, // Center month name
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            ),
            ),

            SizedBox(height: 20),

            // Journal Entry Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Show "Add Entry" only for today and if no entry exists
                  if (isToday && !_hasEntry)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          _showTextField = true;
                        });
                      },
                      child: Text("Add Entry"),
                    ),

                  // If entry exists, show "View" and "Edit"
                  if (_hasEntry)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _showTextField = true;
                            });
                          },
                          child: Text("View"),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                              _showTextField = true;
                            });
                          },
                          child: Text("Edit"),
                        ),
                      ],
                    ),

                  // If it's a past date and no entry exists, show "No entry available"
                  if (isPastDate && !_hasEntry)
                    Text(
                      "No entry available for this date.",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),

                  SizedBox(height: 10),

                  // Show TextField when Add/Edit/View is clicked
                  if (_showTextField)
                    Column(
                      children: [
                        TextField(
                          controller: _journalController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: "Write your journal here...",
                            border: OutlineInputBorder(),
                          ),
                          readOnly: !_isEditing,
                        ),

                        SizedBox(height: 10),

                        if (_isEditing)
                          ElevatedButton(
                            onPressed: _saveJournalEntry,
                            child: Text("Save Journal"),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
