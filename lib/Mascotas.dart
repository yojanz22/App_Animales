import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MascotasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animales Perdidos'),
      ),
      body: _buildPerdidosGrid(),
    );
  }

  Widget _buildPerdidosGrid() {
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
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: mascotasPerdidas!.length,
          itemBuilder: (context, index) {
            var mascota = mascotasPerdidas[index];
            var nombre = mascota['nombre'];
            var imageUrl = mascota['imagen'];

            return _buildMascotaPerdidaCard(nombre, imageUrl);
          },
        );
      },
    );
  }

  Widget _buildMascotaPerdidaCard(String nombre, String imageUrl) {
    return Card(
      child: Column(
        children: [
          Image.network(
            imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8.0),
          Text(
            nombre,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
