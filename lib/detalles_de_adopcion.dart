import 'package:flutter/material.dart';

class DetallesDeAdopcion extends StatelessWidget {
  final Map<String, dynamic> adopcion;

  DetallesDeAdopcion({required this.adopcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Adopción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${adopcion['nombre']}'),
            Text('Edad: ${adopcion['edad']} ${adopcion['tipoEdad']}'),
            Text('Esterilizado: ${adopcion['esterilizado']}'),
            Text('Peso: ${adopcion['peso']} ${adopcion['tipoPeso']}'),

            // Mostrar imágenes
            if (adopcion['imagenes'] != null && adopcion['imagenes'].length > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Imágenes:'),
                  for (var i = 0; i < adopcion['imagenes'].length; i++)
                    Image.network(
                      adopcion['imagenes'][i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                ],
              ),

            // Agrega más detalles según tus necesidades

            // Botón para hablar con el dueño
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para iniciar una conversación con el dueño
                // Puedes usar algún servicio de mensajería o implementar tu propio flujo de chat.
              },
              child: Text('Hablar con el dueño'),
            ),
          ],
        ),
      ),
    );
  }
}
