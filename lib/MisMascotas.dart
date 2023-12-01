import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MisMascotasPage extends StatefulWidget {
  @override
  _MisMascotasPageState createState() => _MisMascotasPageState();
}

class _MisMascotasPageState extends State<MisMascotasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Mascotas'),
      ),
      body: _buildMascotasList(),
    );
  }

  Widget _buildMascotasList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('mascotas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var mascotas = snapshot.data?.docs;
        List<Widget> mascotasWidgets = [];

        for (var mascota in mascotas!) {
          var nombre = mascota['nombre'];
          var tipo = mascota['tipo'];
          var raza = mascota['raza'];
          // Agrega más campos según sea necesario

          var mascotaWidget = ListTile(
            title: Text(nombre),
            subtitle: Text('Tipo: $tipo - Raza: $raza'),
            // Agrega más elementos según sea necesario
          );

          mascotasWidgets.add(mascotaWidget);
        }

        return ListView(
          children: mascotasWidgets,
        );
      },
    );
  }
}
