import 'package:appanimales/Menu.dart';
import 'package:appanimales/RegistroPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Obtain the authenticated user after successful login
      User? user = FirebaseAuth.instance.currentUser;

      // Navigate to the MenuPage passing the user as a parameter
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(user: user),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en el inicio de sesión: $e';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credential
      await _auth.signInWithCredential(credential);

      // Obtain user information from GoogleSignInAccount
      final GoogleSignInAccount? currentUser = await GoogleSignIn().currentUser;
      String displayName = currentUser?.displayName ?? "No Name";
      String email = currentUser?.email ?? "No Email";

      // Display the user's name
      print("User's Display Name: $displayName");

      // Get the authenticated user
      User? user = FirebaseAuth.instance.currentUser;

      // Navigate to the MenuPage passing the user as a parameter
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(user: user),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en el inicio de sesión con Google: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  child: Text('Google'),
                ),
                SizedBox(width: 10),
                // Other authentication buttons if needed
              ],
            ),
            SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroPage()),
                );
              },
              child: Text('¿No tienes una cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
