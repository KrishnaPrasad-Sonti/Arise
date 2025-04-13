import 'package:flutter/material.dart';
import 'package:mobile_frontend/screens/hiddenarise.dart';


class AriseAi extends StatefulWidget {
  final String userId;

  const AriseAi({super.key, required this.userId});

  @override
  State<AriseAi> createState() => _AriseAiState();
}

class _AriseAiState extends State<AriseAi> {
  int _tapCount = 0;

  void _handleTap() {
    setState(() {
      _tapCount++;
      if (_tapCount == 3) {
        _tapCount = 0; // Reset counter
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  Hiddenarise(userId: widget.userId)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/test1.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: GestureDetector(
                onTap: _handleTap,
                child: Text(
                  "Arise",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "MinervaModern",
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


