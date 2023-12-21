import 'package:flutter/material.dart';

class EditarMascotaPage extends StatelessWidget {
  final Map<String, dynamic> mascota;

  EditarMascotaPage({required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Mascota'),
      ),
      body: Center(
        child: Text('Editar detalles de la mascota con ID: ${mascota['id']}'),
      ),
    );
  }
}
