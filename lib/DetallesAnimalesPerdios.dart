import 'package:appanimales/MapaGoogleUnico.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'GoogleMap.dart'; // Importa tu archivo GoogleMap.dart aquí

class DetallesAnimalesPerdidos extends StatefulWidget {
  final Map<String, dynamic> ubicacionPerdida;
  final String nombre;
  final String horaPerdida;
  final String fechaPerdida;
  final String descripcion;
  final String imageUrl;
  final double? recompensa;
  final String nombreUsuario; // Nueva adición: nombreUsuario

  DetallesAnimalesPerdidos({
    required this.ubicacionPerdida,
    required this.nombre,
    required this.horaPerdida,
    required this.fechaPerdida,
    required this.descripcion,
    required this.imageUrl,
    this.recompensa,
    required this.nombreUsuario, // Nueva adición: nombreUsuario
  });

  @override
  _DetallesAnimalesPerdidosState createState() =>
      _DetallesAnimalesPerdidosState();
}

class _DetallesAnimalesPerdidosState extends State<DetallesAnimalesPerdidos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombre,
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
                    widget.nombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.network(widget.imageUrl, width: 150, height: 150),
                ],
              ),
            ),
            SizedBox(height: 10),
            _buildDetalle('Hora de Pérdida', _formatHoraPerdida()),
            _buildDetalle('Fecha de Pérdida', widget.fechaPerdida),
            _buildDetalle('Descripción', widget.descripcion),
            _buildRecompensa(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _mostrarDialogoContactar(context);
              },
              child: Text('Hablar con el Dueño (${widget.nombreUsuario})'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _mostrarEnMapa(context);
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
      DateTime parsedTime = DateFormat.jm().parse(widget.horaPerdida);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return widget.horaPerdida;
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
    return widget.recompensa != null
        ? Container(
            color: Colors.amber,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.attach_money),
                SizedBox(width: 5),
                Text('Recompensa: \$${widget.recompensa!.toString()}'),
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
            'Puedes contactar al dueño del animal (${widget.nombreUsuario}) a través de la aplicación.',
          ),
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

  void _mostrarEnMapa(BuildContext context) {
    double latitude = widget.ubicacionPerdida['latitude'];
    double longitude = widget.ubicacionPerdida['longitude'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapaGoogleUnico(
          ubicacion: LatLng(latitude, longitude),
        ),
      ),
    );
  }
}
