import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nombreUsuarioActual;
  final String correoActual;
  final String telefonoActual;
  final String direccionActual;
  final String nombreCompletoActual;

  EditarPerfilPage({
    required this.nombreUsuarioActual,
    required this.correoActual,
    required this.telefonoActual,
    required this.direccionActual,
    required this.nombreCompletoActual,
  });

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.nombreCompletoActual);
    _telefonoController = TextEditingController(text: widget.telefonoActual);
    _direccionController = TextEditingController(text: widget.direccionActual);
  }

  void _guardarCambios() async {
    String nuevoNombreCompleto = _nombreController.text;
    String nuevoTelefono = _telefonoController.text;
    String nuevaDireccion = _direccionController.text;

    try {
      // Obtén la ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Actualiza el documento en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        'nombreCompleto': nuevoNombreCompleto,
        'telefono': nuevoTelefono,
        'direccion': nuevaDireccion,
      });

      Navigator.pop(context); // Cierra la página de edición de perfil
    } catch (error) {
      print('Error al actualizar el perfil: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nombre de Usuario: ${widget.nombreUsuarioActual}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nuevo Nombre Completo'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Nuevo Teléfono'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(labelText: 'Nueva Dirección'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
