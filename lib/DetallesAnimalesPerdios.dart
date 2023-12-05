import 'package:flutter/material.dart';

class DetallesAnimalesPerdidos extends StatelessWidget {
  final String nombre;
  final String ultimaUbicacion;
  final String horaPerdida;
  final String descripcion;
  final String imageUrl;

  DetallesAnimalesPerdidos({
    required this.nombre,
    required this.ultimaUbicacion,
    required this.horaPerdida,
    required this.descripcion,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Animal Perdido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl, width: 100, height: 100),
            SizedBox(height: 10),
            Text('Nombre: $nombre'),
            Text('Hora de Pérdida: $horaPerdida'),
            Text('Última Ubicación: $ultimaUbicacion'),
            Text('Descripción: $descripcion'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Agrega la lógica para "Hablar con el dueño"
              },
              child: Text('Hablar con el Dueño'),
            ),
          ],
        ),
      ),
    );
  }
}
