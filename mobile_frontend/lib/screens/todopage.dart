import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Todopage extends StatefulWidget {
  const Todopage({super.key});

  @override
  State<Todopage> createState() => _TodoPageState();
}

class _TodoPageState extends State<Todopage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks using 'tasks_in_todo'
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? taskData = prefs.getString('tasks_in_todo'); // Changed key

    if(taskData ==null)
    {
      setState(() {
        tasks=[];// this will intialize an empty list
      });
      return ;
    }
    
    List<dynamic> decodedData = json.decode(taskData);
    setState(() {
      tasks = decodedData.map<Map<String, dynamic>>((task) {
        return {
          'name': task['name'] ?? 'Unnamed Task',
          'completed': task['completed'] ?? false,
          'subtasks': (task['subtasks'] as List<dynamic>?)
                  ?.map<Map<String, dynamic>>((subtask) => {
                        'name': subtask['name'] ?? 'Unnamed Subtask',
                        'completed': subtask['completed'] ?? false,
                      })
                  .toList() ??
              [],
          'expanded': task['expanded'] ?? false,
        };
      }).toList();
    });
    }

  // Save tasks using 'tasks_in_todo'
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonTasks = jsonEncode(tasks);
    await prefs.setString('tasks_in_todo', jsonTasks); // Changed key
  }

  void _addTask() {
    setState(() {
      tasks.add({
        'name': 'New Task',
        'completed': false,
        'subtasks': [],
        'expanded': false,
      });
    });
    _saveTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
    _saveTasks();
  }

  void _toggleExpand(int index) {
    setState(() {
      tasks[index]['expanded'] = !tasks[index]['expanded'];
    });
  }

  void _editTask(int index) {
    TextEditingController controller =
        TextEditingController(text: tasks[index]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Task Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                tasks[index]['name'] = controller.text;
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _addSubtask(int index) {
    TextEditingController subtaskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Subtask"),
        content: TextField(
          controller: subtaskController,
          decoration: InputDecoration(hintText: "Subtask Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                tasks[index]['subtasks'].add({
                  'name': subtaskController.text,
                  'completed': false,
                });
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _toggleSubtask(int taskIndex, int subtaskIndex) {
    setState(() {
      tasks[taskIndex]['subtasks'][subtaskIndex]['completed'] =
          !tasks[taskIndex]['subtasks'][subtaskIndex]['completed'];
    });
    _saveTasks();
  }

  void _deleteSubtask(int taskIndex, int subtaskIndex) {
    setState(() {
      tasks[taskIndex]['subtasks'].removeAt(subtaskIndex);
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: tasks[index]['completed'] ?? false,
                            onChanged: (_) => _toggleTask(index),
                          ),
                          Text(
                            tasks[index]['name'],
                            style: TextStyle(
                              fontSize: 18,
                              decoration: tasks[index]['completed']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _addSubtask(index),
                          ),
                          IconButton(
                            icon: tasks[index]['expanded']
                                ? Icon(Icons.expand_less)
                                : Icon(Icons.expand_more),
                            onPressed: () => _toggleExpand(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: const Color.fromARGB(255, 133, 44, 145)),
                            onPressed: () => _deleteTask(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (tasks[index]['expanded'] && tasks[index]['subtasks'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Column(
                        children: tasks[index]['subtasks']
                            .asMap()
                            .entries
                            .map<Widget>((entry) {
                          int subtaskIndex = entry.key;
                          var subtask = entry.value;
                          return Row(
                            children: [
                              Checkbox(
                                value: subtask['completed'] ?? false,
                                onChanged: (_) =>
                                    _toggleSubtask(index, subtaskIndex),
                              ),
                              Text(
                                subtask['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: subtask['completed']
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteSubtask(index, subtaskIndex),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}
