import 'package:flutter/material.dart';

class Walpapertesting extends StatelessWidget {
  const Walpapertesting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homewal.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: const Center(
          child: Text(
            '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
