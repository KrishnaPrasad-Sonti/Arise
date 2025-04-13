import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up (Register)
  Future<String?> signup(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase error messages
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Login
 Future<String?> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user?.uid;
  } 
  on FirebaseAuthException catch (e) 
  {
    developer.log("Firebase Error: ${e.code} - ${e.message}");
    return null;  // Ensure it returns null explicitly if login fails
  } 
  catch (e) {
    developer.log("Error: $e");
    return null;
  }
}

 // NEW: Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      developer.log("Google Sign-In error: $e");
      return null;
    }
  }
// above is google signin logic


  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
