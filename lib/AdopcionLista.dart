import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalles_de_adopcion.dart';

class ListaAnimalesAdopcion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Animales en Adopción'),
      ),
      body: _buildListaAnimales(context),
    );
  }

  Widget _buildListaAnimales(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('animales_adopcion')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los datos.'));
        }

        // Obtén los documentos de la colección
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
    String imageUrl = ""; // Aquí almacenaremos la URL de la imagen
    if (animal['imagenes'] != null && animal['imagenes'].isNotEmpty) {
      imageUrl = animal['imagenes'][0]; // Tomamos la primera imagen
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
            : SizedBox(width: 80, height: 80), // Placeholder si no hay imagen
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesDeAdopcion(adopcion: animal),
            ),
          );
        },
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }
}
