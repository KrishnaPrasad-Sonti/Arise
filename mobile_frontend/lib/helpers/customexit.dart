import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:mobile_frontend/screens/login_screen.dart';
import 'package:mobile_frontend/services/auth_services.dart';

Future<void> showCustomDialog(BuildContext context) async {
  bool? exitApp = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.black,
      title: const Text(
        "Exit App",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "Yes, I know, you were merely a human.\n\nGo ahead to Quit",
        style: TextStyle(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Colors.blueAccent,
          width: 2,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "No",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );

  if (exitApp == true) {
    // Call logout
    await AuthService().signOut();

    // Close the app completely
    if (context.mounted) {
      SystemNavigator.pop(); // This will close the app
    }
  }
}
