import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgregarMascotaPage extends StatefulWidget {
  @override
  _AgregarMascotaPageState createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  final TextEditingController _nombreMascotaController =
      TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _agregarMascota() async {
    try {
      // Obtener al usuario actual
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Obtener datos del usuario actual desde la base de datos
        DocumentSnapshot userData =
            await _firestore.collection('usuarios').doc(currentUser.uid).get();

        // Obtener el ID del usuario actual
        String userId = currentUser.uid;

        // Agregar mascota a la base de datos
        await _firestore.collection('mascotas').add({
          'nombre': _nombreMascotaController.text,
          'raza': _razaController.text,
          'edad': _edadController.text,
          'idUsuario': userId,
          // Otros campos de la mascota...
        });

        // Mensaje de confirmación
        print('Mascota agregada con éxito.');
      }
    } catch (e) {
      // Manejo de errores
      print('Error al agregar la mascota: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nombreMascotaController,
              decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _razaController,
              decoration: InputDecoration(labelText: 'Raza'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _edadController,
              decoration: InputDecoration(labelText: 'Edad'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agregarMascota,
              child: Text('Agregar Mascota'),
            ),
          ],
        ),
      ),
    );
  }
}
