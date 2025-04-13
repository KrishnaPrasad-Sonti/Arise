import 'dart:convert';  // Importing required libraries
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class UserService {

  // Method to register a user
  Future<String> signup(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "username": username,
        "password": password,
      }), 
    );

    if (response.statusCode == 201) {
      return "User registered successfully!";
    } else { 
      return "Failed to register user: ${response.body}";
    }
  }

        // this is  http request for login 
        // 
 
 

 Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['email']; // Extract and return only the email
    } else {
      return null; // Login failed
    }
  }

  

}
