import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskSpinner extends StatefulWidget {
  const TaskSpinner({super.key});

  @override
  State<TaskSpinner> createState() => _TaskSpinnerState();
}

class _TaskSpinnerState extends State<TaskSpinner> {
  final TextEditingController _taskController = TextEditingController();
  final StreamController<int> _controller = StreamController<int>.broadcast();
  List<String> tasks = [];
  bool isLoading = true; // <-- To handle async loading

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskData = prefs.getStringList('tasks') ?? [];

    setState(() {
      tasks = taskData;
      isLoading = false; // <-- Set loading to false once tasks are loaded
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', tasks);
  }

  void _addTask() {
    if (_taskController.text.trim().isNotEmpty) {
      setState(() {
        tasks.add(_taskController.text.trim());
        _taskController.clear();
      });
      _saveTasks();
    } else {
      _showSnackBar("Task cannot be empty.");
    }
  }

  void _removeTask(int index) {
    if (tasks.length > 1) {
      setState(() {
        tasks.removeAt(index);
      });
      _saveTasks();
    } else {
      _showSnackBar("At least two tasks are required to spin.");
    }
  }

  void _editTask(int index) {
    TextEditingController editController = TextEditingController(text: tasks[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Enter new task name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tasks[index] = editController.text.trim();
                });
                _saveTasks();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _spinWheel() {
    if (tasks.length > 1) {
      int randomIndex = Random().nextInt(tasks.length);
      _controller.add(randomIndex);
    } else {
      _showSnackBar("Add at least two tasks before spinning.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text("       Task Spinner"), 
      foregroundColor: Colors.white,
      backgroundColor: Color.fromARGB(255, 80, 0, 115),),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // <-- Show loading state
          : Column(
              children: [
                SizedBox(
                  height: 250,
                  child: tasks.length > 1
                      ? FortuneWheel(
                          selected: _controller.stream,
                          items: tasks.map((task) => FortuneItem(child: Text(task))).toList(),
                        )
                      : const Center(child: Text("Add at least two tasks to spin", style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _spinWheel,
                  child: const Text("Spin"),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: "Enter a task",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTask,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(tasks[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTask(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTask(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _taskController.dispose();
    super.dispose();
  }
}
