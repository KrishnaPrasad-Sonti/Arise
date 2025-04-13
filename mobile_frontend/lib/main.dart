import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_frontend/helpers/notification_helper.dart';
import 'package:mobile_frontend/helpers/uidhelper.dart';
import 'package:mobile_frontend/screens/welcome_screen.dart';
import 'package:mobile_frontend/screens/signup_screen.dart';
import 'package:mobile_frontend/screens/login_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;




void setupTimeZone() {
  tz.initializeTimeZones();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupTimeZone();

  // Initialize notifications
  await NotificationHelper.initializeLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(NotificationHelper.firebaseMessagingBackgroundHandler);

    
   String? userId = await  UidHelper.getUid();

  
   
    debugPrint("now calling the schedule remainder ,because it is in if loop ");

  NotificationHelper.scheduleTomorrowReminders(userId);
  debugPrint("now i already called , hope that works");
 
  
  

  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
