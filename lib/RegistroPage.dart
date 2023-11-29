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

  String generarNombreUsuario(String nombreCompleto) {
    String primerNombre = nombreCompleto.split(' ')[0];
    Random random = Random();
    int numeroAleatorio = random.nextInt(10000); // Máximo de 4 dígitos
    return '$primerNombre$numeroAleatorio';
  }

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

        // Generar nombre de usuario con el primer nombre y un máximo de 4 números aleatorios
        String nombreUsuario = generarNombreUsuario(_nombreController.text);

        await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'nombreCompleto': _nombreController.text,
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
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su correo electrónico';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Correo Electrónico'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _telefonoController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su número de teléfono';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Número de Teléfono'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _direccionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su dirección';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Dirección'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su contraseña';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _repeatPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, repita su contraseña';
                    } else if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Repetir Contraseña'),
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
        ),
      ),
    );
  }
}
