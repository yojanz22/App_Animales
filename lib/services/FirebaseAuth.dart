import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name in Firebase authentication
      await _auth.currentUser?.updateDisplayName(displayName);

      return null; // Registration successful, returns null
    } on FirebaseAuthException catch (e) {
      return e.message; // Returns specific error message in case of failure
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sign-in successful, returns null
    } on FirebaseAuthException catch (e) {
      return e.message; // Returns specific error message in case of failure
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
