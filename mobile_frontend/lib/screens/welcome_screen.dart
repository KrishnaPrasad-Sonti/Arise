import 'package:flutter/material.dart';
import 'package:mobile_frontend/screens/login_screen.dart';
import 'package:mobile_frontend/screens/signup_screen.dart';

//import "signupnotificationpage.dart";
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          
          width: screenWidth * 0.8, // 80% of screen width
          height: screenHeight * 0.7, // Increased height (60% of screen height)
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% padding
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 111, 109, 109),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),

          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center, // Centering content
            children: [
              // **Circle Avatar (Image)**
              const CircleAvatar(
                radius: 70, 
                backgroundImage: AssetImage("assets/images/bawsung.png"),
                
              ),

              SizedBox(height: screenHeight * 0.09), // Extra space after image

              // **Inner Container for Buttons & Text**
              Container(
                padding: EdgeInsets.all(screenHeight * 0.02), // 2% padding
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                       onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())
                                         );
                                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Sign Up"),
                    ),

                    SizedBox(height: screenHeight * 0.015), // 1.5% of screen height

                    const Text("Or", style: TextStyle(fontSize: 15,color: Colors.white)),

                    SizedBox(height: screenHeight * 0.015),

                    ElevatedButton(
                      onPressed: () { 
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Login"),
                    ),

                    SizedBox(height: screenHeight * 0.07),
                    

                    const Text(
                      "Made By Krishna Sonti - V1.0",
                      style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
