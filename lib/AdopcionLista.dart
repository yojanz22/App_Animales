import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalles_de_adopcion.dart'; // Asegúrate de importar el archivo detalles_de_adopcion.dart

class ListaAnimalesAdopcion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Animales en Adopción'),
      ),
      body: _buildListaAnimales(
          context), // Pasa el contexto a _buildListaAnimales
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
    // Personaliza este método según la estructura de tus datos
    return Card(
      child: ListTile(
        title: Text('Nombre: ${animal['nombre']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edad: ${animal['edad']} ${animal['tipoEdad']}'),
            Text('Esterilizado: ${animal['esterilizado']}'),
            Text('Peso: ${animal['peso']} ${animal['tipoPeso']}'),

            // Mostrar imágenes
            if (animal['imagenes'] != null && animal['imagenes'].length > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Imágenes:'),
                  for (var i = 0; i < animal['imagenes'].length; i++)
                    Image.network(
                      animal['imagenes'][i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
          ],
        ),
        onTap: () {
          // Navegar a la pantalla de detalles al tocar un elemento
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesDeAdopcion(adopcion: animal),
            ),
          );
        },
      ),
    );
  }
}
