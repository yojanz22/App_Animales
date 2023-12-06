import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl para formatear la fecha

class DetallesAnimalesPerdidos extends StatelessWidget {
  final String nombre;
  final String ultimaUbicacion;
  final String horaPerdida;
  final String fechaPerdida;
  final String descripcion;
  final String imageUrl;
  final double? recompensa;

  DetallesAnimalesPerdidos({
    required this.nombre,
    required this.ultimaUbicacion,
    required this.horaPerdida,
    required this.fechaPerdida,
    required this.descripcion,
    required this.imageUrl,
    this.recompensa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombre,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.network(imageUrl, width: 150, height: 150),
                ],
              ),
            ),
            SizedBox(height: 10),
            _buildDetalle('Hora de Pérdida', _formatHoraPerdida()),
            _buildDetalle('Fecha de Pérdida', fechaPerdida),
            _buildDetalle('Última Ubicación', ultimaUbicacion),
            _buildDetalle('Descripción', descripcion),
            _buildRecompensa(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _mostrarDialogoContactar(context);
              },
              child: Text('Hablar con el Dueño'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Agrega aquí la lógica para manejar el botón de última ubicación
                    },
                    child: Text('Mostrar en el Mapa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHoraPerdida() {
    try {
      // Analiza la horaPerdida en un objeto DateTime
      DateTime parsedTime = DateFormat.jm().parse(horaPerdida);
      // Formatea la horaPerdida en un nuevo formato deseado
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      // Si hay un error al analizar la hora, devuelve la hora original
      return horaPerdida;
    }
  }

  Widget _buildDetalle(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRecompensa() {
    return recompensa != null
        ? Container(
            color: Colors.amber,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.attach_money),
                SizedBox(width: 5),
                Text('Recompensa: \$${recompensa!.toString()}'),
              ],
            ),
          )
        : Container();
  }

  void _mostrarDialogoContactar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contactar al Dueño'),
          content: Text(
              'Puedes contactar al dueño del animal a través de la aplicación.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
