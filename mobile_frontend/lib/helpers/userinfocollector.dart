import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class UserInfoCollector extends StatefulWidget {
  final String userId;

  const UserInfoCollector({super.key, required this.userId});

  @override
  State<UserInfoCollector> createState() => _UserInfoCollectorState();
}

class _UserInfoCollectorState extends State<UserInfoCollector> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndCollectUserInfo();
  }

  Future<Map<String, dynamic>?> _checkAndCollectUserInfo() async {
    DocumentReference userDoc =
        _firestore.collection('user_details').doc(widget.userId);
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      _showUserDetailsDialog();
      return null;
    }

    DocumentSnapshot detailsSnapshot =
        await userDoc.collection('details').doc('user_info').get();

    if (!detailsSnapshot.exists) {
      _showUserDetailsDialog();
      return null;
    }

    return detailsSnapshot.data() as Map<String, dynamic>;
  }

  void _showUserDetailsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Your Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty &&
                    _ageController.text.isNotEmpty) {
                  await _saveUserDetails();
                  Navigator.pop(context);
                } else {
                  developer.log("Please fill in all fields.");
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserDetails() async {
    DocumentReference userDoc =
        _firestore.collection('user_details').doc(widget.userId);

    await userDoc.set({'created_at': FieldValue.serverTimestamp()});

    await userDoc.collection('details').doc('user_info').set({
      'username': _nameController.text,
      'email': _emailController.text,
      'age': int.parse(_ageController.text),
    });

    developer.log("User details saved successfully.");
  }

 @override
Widget build(BuildContext context) {
  return SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 5),



        FutureBuilder<Map<String, dynamic>?>(
          future: _checkAndCollectUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text(
                  "Fetching User Data...",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error fetching data!",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  "No user data available",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            } else {
              Map<String, dynamic> userData = snapshot.data!;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Username
                    Text(
                      userData['username'],
                      style: TextStyle(
                        fontFamily: "MinervaModern",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 10),

                    // Email and Age Row
                    Text(
                      "${userData['email']}  |  ${userData['age']} years",
                      style: TextStyle(
                        fontFamily: "MinervaModern",
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    ),
  );
}
}