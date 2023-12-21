import 'package:appanimales/services/FirebaseAuth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MiAdopcionLista extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Animales en Adopción'),
      ),
      body: _buildListaAnimales(context),
    );
  }

  Widget _buildListaAnimales(BuildContext context) {
    String? currentUserId = _authService.getCurrentUserId();

    if (currentUserId == null) {
      return Center(
        child: Text('Usuario no autenticado'),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('animales_adopcion')
          .where('propietario', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los datos.'));
        }

        List<QueryDocumentSnapshot> documentos = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documentos.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> animal =
                documentos[index].data() as Map<String, dynamic>;
            return _buildAnimalAdopcionCard(context, animal);
          },
        );
      },
    );
  }

  Widget _buildAnimalAdopcionCard(
      BuildContext context, Map<String, dynamic> animal) {
    String imageUrl = "";
    if (animal['imagenes'] != null && animal['imagenes'].isNotEmpty) {
      imageUrl = animal['imagenes'][0];
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          'Nombre: ${animal['nombre']}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edad: ${animal['edad']} ${animal['tipoEdad']}'),
            Text('Esterilizado: ${animal['esterilizado']}'),
            Text('Peso: ${animal['peso']} ${animal['tipoPeso']}'),
          ],
        ),
        leading: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : SizedBox(width: 80, height: 80),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Agrega la lógica para editar aquí
                // Puedes abrir un cuadro de diálogo de edición o navegar a una pantalla de edición.
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Agrega la lógica para eliminar aquí
                // Puedes mostrar un cuadro de diálogo de confirmación antes de eliminar.
              },
            ),
          ],
        ),
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }
}
