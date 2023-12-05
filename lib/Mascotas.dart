import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MascotasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animales Perdidos'),
      ),
      body: _buildPerdidosList(),
    );
  }

  Widget _buildPerdidosList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('mascotas')
          .where('perdida', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var mascotasPerdidas = snapshot.data?.docs;
        return ListView.builder(
          itemCount: mascotasPerdidas!.length,
          itemBuilder: (context, index) {
            var mascota = mascotasPerdidas[index];
            var nombre = mascota['nombre'];
            var ultimaUbicacion = mascota['ultimaDireccionVista'];
            var horaPerdida = mascota['horaPerdida'];
            var descripcion = mascota['descripcion'];
            var imageUrl = mascota['imagen'];

            return _buildMascotaPerdidaCard(
              nombre,
              ultimaUbicacion,
              horaPerdida,
              descripcion,
              imageUrl,
              context,
            );
          },
        );
      },
    );
  }

  Widget _buildMascotaPerdidaCard(
    String nombre,
    String ultimaUbicacion,
    String horaPerdida,
    String descripcion,
    String imageUrl,
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        title: Text(nombre),
        subtitle: Text(ultimaUbicacion),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesAnimalesPerdidos(
                nombre: nombre,
                ultimaUbicacion: ultimaUbicacion,
                horaPerdida: horaPerdida,
                descripcion: descripcion,
                imageUrl: imageUrl,
              ),
            ),
          );
        },
      ),
    );
  }
}
