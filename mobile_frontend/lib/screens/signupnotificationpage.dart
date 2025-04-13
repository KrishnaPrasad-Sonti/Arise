import 'package:flutter/material.dart';

class Signupnotificationpage extends StatelessWidget {
  const Signupnotificationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Dark background for sci-fi feel
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 3), // Sci-fi glowing border
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 191, 255, 0.7), 
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.blueGrey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.warning, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "[SYSTEM WARNING] ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.blueAccent),
              const SizedBox(height: 10),
              const Text(
                "Once you enter, there’s no turning back...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                "Will you accept?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Row for YES and NO buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shadowColor: Colors.blueAccent,
                      elevation: 10,
                    ),
                    child: const Text("YES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigates back to the previous page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shadowColor: Colors.white,
                      elevation: 10,
                    ),
                    child: const Text("NO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
