import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Goaltracker extends StatefulWidget {
  const Goaltracker({super.key});

  @override
  State<Goaltracker> createState() => _GoaltrackerState();
}

class _GoaltrackerState extends State<Goaltracker> {
  List<Map<String, dynamic>> goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedGoals = prefs.getString('goals');
    if (storedGoals != null) {
      setState(() {
        goals = List<Map<String, dynamic>>.from(json.decode(storedGoals));
      });
    }
  }

  void _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('goals', json.encode(goals));
  }

  void _addGoal() {
    TextEditingController goalController = TextEditingController();
    List<Map<String, dynamic>> subtasks = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Enter Goal"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: goalController,
                    decoration: const InputDecoration(labelText: "Goal Name"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() {
                        subtasks.add({"title": "New Task", "completed": false});
                      });
                    },
                    child: const Text("Add Subtask"),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: subtasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(subtasks[index]["title"]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255,80,0,115)),
                            onPressed: () {
                              setDialogState(() {
                                subtasks.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (goalController.text.isNotEmpty) {
                      setState(() {
                        goals.add({
                          "description": goalController.text,
                          "progress": 0.0,
                          "subtasks": subtasks,
                        });
                        _saveGoals();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Goal"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateProgress(int index) {
    List subtasks = goals[index]["subtasks"];
    int completedTasks = subtasks.where((task) => task["completed"]).length;
    double progress = subtasks.isEmpty ? 0.0 : completedTasks / subtasks.length;

    setState(() {
      goals[index]["progress"] = progress;
      _saveGoals();
    });
  }

 

  void _editGoal(int index) {
    TextEditingController subtaskController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Subtasks"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: goals[index]["subtasks"].length,
                      itemBuilder: (context, subIndex) {
                        return ListTile(
                          leading: Checkbox(
                            value: goals[index]["subtasks"][subIndex]["completed"],
                            onChanged: (value) {
                              setState(() {
                                goals[index]["subtasks"][subIndex]["completed"] = value!;
                                _updateProgress(index);
                              });
                              setDialogState(() {});
                            },
                          ),
                          title: Text(goals[index]["subtasks"][subIndex]["title"]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255,80,0,115)),
                            onPressed: () {
                              setState(() {
                                goals[index]["subtasks"].removeAt(subIndex);
                                _updateProgress(index);
                              });
                              setDialogState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: subtaskController,
                    decoration: const InputDecoration(labelText: "New Subtask"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (subtaskController.text.isNotEmpty) {
                        setState(() {
                          goals[index]["subtasks"].add({
                            "title": subtaskController.text,
                            "completed": false,
                          });
                          _saveGoals();
                        });
                        setDialogState(() {});
                        subtaskController.clear();
                      }
                    },
                    child: const Text("Add Subtask"),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteGoal(int index) {
    setState(() {
      goals.removeAt(index);
      _saveGoals();
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Padding( // Wrap the Column in a Padding widget
      padding: const EdgeInsets.only(top: 50.0),
      child: Column( // Add the child parameter here
        children: [
          const Text(
            "Your Goals - Here's Your Tracker",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _editGoal(index),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircularProgressIndicator(
                              value: goals[index]["progress"],
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Progress: ${(goals[index]["progress"] * 100).toInt()}%",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(goals[index]["description"],
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(255,80,0,115)),
                              onPressed: () => _deleteGoal(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: _addGoal,
              child: const Text("Add Goal"),
            ),
          ),
        ],
      ),
    ),
  );
}}