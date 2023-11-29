import 'package:appanimales/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  String _errorText = '';
  final _formKey =
      GlobalKey<FormState>(); // Agrega una clave global para el formulario

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Formulario válido
      if (_passwordController.text != _repeatPasswordController.text) {
        setState(() {
          _errorText = 'Las contraseñas no coinciden.';
        });
        return;
      }

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Generar nombre de usuario con el primer nombre y un número único
        String nombreUsuario = _nombreController.text.split(' ')[0] +
            DateTime.now().millisecondsSinceEpoch.toString();

        await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nombre': _nombreController.text,
          'email': _emailController.text,
          'telefono': _telefonoController.text,
          'direccion': _direccionController.text,
          'nombreUsuario': nombreUsuario,
        });

        print('Registro exitoso.');

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... (Otros campos)
                TextFormField(
                  controller: _nombreController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nombre';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Nombre completo'),
                ),
                SizedBox(height: 10),
                // ... (Otros campos)
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
        ),
      ),
    );
  }
}
