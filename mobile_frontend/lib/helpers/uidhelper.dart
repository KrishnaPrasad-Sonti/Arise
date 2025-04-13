import 'package:shared_preferences/shared_preferences.dart';

class UidHelper {
  static String? _userId;

  // 🔹 Save userId in SharedPreferences
  static Future<void> setUid(String userId) async {
    _userId = userId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }
  
  // 🔹 Retrieve userId from SharedPreferences
  static Future<String?> getUid() async {
    if (_userId != null) return _userId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    return _userId;
  }

  // 🔹 Remove userId when user logs out
  static Future<void> clearUid() async {
    _userId = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}


