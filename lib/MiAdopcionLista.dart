// mi_adopcion_lista.dart
import 'package:appanimales/DetallesAnimalesAdopcion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalles_de_adopcion.dart';

class MiAdopcionLista extends StatelessWidget {
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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('animales_adopcion')
          .where('propietario', isEqualTo: getCurrentUserId())
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
                _navigateToEditScreen(context, animal);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, animal);
              },
            ),
          ],
        ),
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }

  void _navigateToEditScreen(
      BuildContext context, Map<String, dynamic> animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesAnimalesAdopcion(animal: animal),
      ),
    ).then((result) {
      if (result != null && result['animalActualizado'] == true) {
        // Implementa lógica para actualizar la lista si es necesario
        // Puedes recargar la lista o realizar otras acciones según tus necesidades
        // Por ejemplo, podrías utilizar un StreamController para actualizar la lista
      }
    });
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Map<String, dynamic> animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Animal'),
          content: Text('¿Estás seguro de que quieres eliminar este animal?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _eliminarAnimal(animal['id']);
                Navigator.pop(context);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarAnimal(String animalId) {
    try {
      FirebaseFirestore.instance
          .collection('animales_adopcion')
          .doc(animalId)
          .delete();
      print('Animal eliminado correctamente.');
    } catch (e) {
      print('Error al eliminar el animal: $e');
    }
  }

  String getCurrentUserId() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return userId ?? '';
  }
}
