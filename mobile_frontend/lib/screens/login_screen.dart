import 'package:flutter/material.dart';
import 'package:mobile_frontend/helpers/uidhelper.dart';
import 'package:mobile_frontend/screens/homescreen.dart';
import 'package:mobile_frontend/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  // Function to save user email in local storage
  Future<void> _saveUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Login function----------

Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    developer.log("Attempting login with Email: $email");

    // Call AuthService for authentication
    final String? response = await _authService.signIn(email, password);

    setState(() {
      _isLoading = false;
    });

    if (response != null) 
    {
      developer.log("Login successful, UID: $response");
      UidHelper.setUid(response); // this will save the userid in shared preferece

      await _saveUserEmail(response);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen(userId: response)), 
      );
    } else {
      setState(() {
        _errorMessage = "Invalid credentials. Please try again.";
      });
    }
  } catch (e) {
    developer.log("Unexpected error: $e");
    setState(() {
      _isLoading = false;
      _errorMessage = "An error occurred. Please try again.";
    });
  }
}

Future<void> _handleGoogleSignIn() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final user = await _authService.signInWithGoogle();

  setState(() => _isLoading = false);

  if (user != null) {
    final uid = user.uid;
    developer.log("Google login success, UID: $uid");

    UidHelper.setUid(uid); // Save UID
    await _saveUserEmail(user.email ?? ''); // Save email

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homescreen(userId: uid)),
    );
  } else {
    setState(() {
      _errorMessage = "Google sign-in failed. Try again.";
    });
  }
}



    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/landscape.jpg',
              fit: BoxFit.fitHeight,
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 350,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email, color: Colors.white70),
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),
ElevatedButton.icon(
  icon: const Icon(Icons.login),
  label: const Text("Sign in with Google"),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 61, 6, 75),
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  onPressed: _isLoading ? null : _handleGoogleSignIn,
),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
