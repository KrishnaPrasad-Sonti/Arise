import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:mobile_frontend/screens/focussession.dart';
import 'package:mobile_frontend/screens/taskmanager.dart';
import 'package:mobile_frontend/screens/taskspinner.dart';

class Workmanager extends StatefulWidget {
  final String userId;

  const Workmanager({super.key, required this.userId});

  @override
  State<Workmanager> createState() => _TaskManageState();
}

class _TaskManageState extends State<Workmanager> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **Custom Text Instead of Logo**
            Text(
              "Arise",
               style: TextStyle(
                     fontFamily: "MinervaModern", // Use the defined font family
                    fontSize: screenWidth * 0.1, // Adjust size dynamically
                  fontWeight: FontWeight.bold,



                 color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // **Description**
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: const Text(
                "Want to kickstart? Here is the Work Manager",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // **Lottie Animation**
            Center(
              child: Lottie.asset(
                'assets/animations/todolist.json',
                width: screenWidth * 0.7,
                height: screenHeight * 0.3,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),

            // **Buttons Section**
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,  MaterialPageRoute(builder: (context) => Taskmanager(userId: widget.userId), ),);
                            },
                            
              child: const Text("Task-Manager"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  FocusTimerApp()),
                              );
              },
              child: const Text("Focus Sessions"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                 Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TaskSpinner()),
                              );
              },
              child: const Text("Task Spinner"),
            ),
          ],
        ),
      ),
    );
  }
}
