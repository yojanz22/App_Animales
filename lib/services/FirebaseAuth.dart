import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro de usuario con correo y contraseña
  Future<String?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Registro exitoso, devuelve null
    } catch (e) {
      return e.toString(); // Devuelve el mensaje de error en caso de fallo
    }
  }

  // Inicio de sesión con correo y contraseña
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Inicio de sesión exitoso, devuelve null
    } catch (e) {
      return e.toString(); // Devuelve el mensaje de error en caso de fallo
    }
  }

  // Cierre de sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener información del usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
