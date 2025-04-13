import 'package:flutter/material.dart';

showCustomDialog(BuildContext context) async {
  bool? exitApp = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.black, // Black background
      title: const Text(
        "Exit App",
        style: TextStyle(color: Colors.white), // White title text
      ),
      content: const Text(
        "Yes, I know, you were merely a human.\n\n Go ahead to Quit",
        style: TextStyle(color: Colors.white), // White content text
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        side: const BorderSide(
          color: Colors.blueAccent, // Electric Blue Outline
          width: 2,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "No",
            style: TextStyle(
              color: Colors.blue, // Blue color for "No" button
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            "Yes",
            style: TextStyle(
              color: Colors.blue, // Blue color for "Yes" button
            ),
          ),
        ),
      ],
    ),
  );

  return exitApp;
}
