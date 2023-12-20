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

      // Actualiza el nombre del usuario en la autenticación de Firebase
      await _auth.currentUser?.updateDisplayName(displayName);

      return null; // Registro exitoso, devuelve null
    } on FirebaseAuthException catch (e) {
      return e
          .message; // Devuelve el mensaje de error específico en caso de fallo
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Inicio de sesión exitoso, devuelve null
    } on FirebaseAuthException catch (e) {
      return e
          .message; // Devuelve el mensaje de error específico en caso de fallo
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
}
