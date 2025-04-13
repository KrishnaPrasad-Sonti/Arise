import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_frontend/helpers/customexit.dart';
import 'package:mobile_frontend/screens/arisepage.dart';
import 'package:mobile_frontend/screens/emotionmanage.dart';
import 'package:mobile_frontend/screens/journal.dart';
import 'package:mobile_frontend/screens/profile.dart';
import 'package:mobile_frontend/screens/workmanager.dart';

class Homescreen extends StatefulWidget {
  final String userId;

  const Homescreen({super.key, required this.userId});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<Homescreen> {
  int _currentIndex = 2; // Default index (Center button selected)

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Workmanager(userId: widget.userId),
      JournalPage(userId: widget.userId),
      AriseAi(userId: widget.userId), // Center page
      EmotionManage(userId: widget.userId),
      Profile(userId: widget.userId),
    ];

    return PopScope(
      canPop: false, // Prevents default back behavior
      onPopInvokedWithResult: (didPop, result) async {
  if (!didPop) {
    await showCustomDialog(context); // Already doing what it should
  }
},


      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          items: const [
            Icon(Icons.check_box, size: 30),
            Icon(Icons.book, size: 30),
            ImageIcon(AssetImage('assets/images/fly.png'), size: 40), // Center logo
            Icon(Icons.self_improvement, size: 30),
            Icon(Icons.person, size: 30),
          ],
          color: const Color.fromARGB(255, 139, 137, 137),
          backgroundColor: Colors.white,
          buttonBackgroundColor: Colors.blue,
          height: 55,
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
