import 'package:appanimales/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  String _errorText = '';

  Future<void> _register() async {
    if (_passwordController.text != _repeatPasswordController.text) {
      setState(() {
        _errorText = 'Las contraseñas no coinciden.';
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Guardar información adicional sobre el usuario en Firestore
      // Puedes agregar más campos según tus necesidades
      await _firestore.collection('usuarios').doc(_emailController.text).set({
        'nombre': _nombreController.text,
        'email': _emailController.text,
        // Otros campos según tus necesidades
      });

      // Navegar a la página principal o realizar acciones adicionales después del registro.
      print('Registro exitoso.');

      // Redirigir a la página de inicio de sesión con el correo electrónico registrado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _errorText = 'La contraseña es demasiado débil.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _errorText = 'La dirección de correo electrónico ya está en uso.';
        });
      } else {
        setState(() {
          _errorText = 'Error en el registro: $e';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'Error en el registro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre completo'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _repeatPasswordController,
              decoration: InputDecoration(labelText: 'Repetir contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrarse'),
            ),
            SizedBox(height: 10),
            Text(
              _errorText,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Ya tengo una cuenta. Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
