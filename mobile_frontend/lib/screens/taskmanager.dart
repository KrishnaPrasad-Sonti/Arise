import 'package:flutter/material.dart';
import 'package:mobile_frontend/screens/goaltracker.dart';
import 'package:mobile_frontend/screens/taskremainder.dart';
import 'package:mobile_frontend/screens/todopage.dart';

class Taskmanager extends StatefulWidget {
  final String userId;

  const Taskmanager({super.key, required this.userId});

  @override
  State<Taskmanager> createState() => _TaskmanagerState();
}

class _TaskmanagerState extends State<Taskmanager> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 222, 220),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 80, 0, 115),
        title: const Text(
          "Task Manager",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Active tab text color
          unselectedLabelColor: Colors.white70, // **Improved visibility for inactive tabs**
          indicatorColor: Colors.white, // **Indicator color for the active tab**
          indicatorWeight: 4.0, // **Thicker underline for the selected tab**
          labelPadding: const EdgeInsets.symmetric(vertical: 10), // **More spacing**
          tabs: const [
            Tab(child: Text("To-Do", style: TextStyle(fontWeight: FontWeight.bold))),
            Tab(child: Text("Reminders", style: TextStyle(fontWeight: FontWeight.bold))),
            Tab(child: Text("Goals", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 80, 0, 115), // Dark purple
              Color.fromARGB(255, 133, 44, 145) // Light purple  - inka light purple const Color.fromARGB(255, 169, 115, 175)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            Todopage(),
            Taskreminder(userId: widget.userId),
            Goaltracker(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
