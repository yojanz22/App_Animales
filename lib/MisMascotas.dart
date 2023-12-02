import 'package:appanimales/editarMascota.dart';
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

          var iconoMascota = tipo == 'Perro'
              ? Image.asset('assets/perro.jpeg', width: 24, height: 24)
              : Image.asset('assets/gato.jpeg', width: 24, height: 24);

          var mascotaWidget = ListTile(
            leading: iconoMascota,
            title: Text(nombre),
            subtitle: Text('Tipo: $tipo - Raza: $raza'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navegar a la página de edición cuando se presiona el botón "Editar"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarMascotaPage(mascota: mascota),
                  ),
                );
              },
            ),
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
