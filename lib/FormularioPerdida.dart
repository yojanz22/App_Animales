import 'package:flutter/material.dart';
import 'package:appanimales/services/SeleccionarUbicacionEnMapa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FormularioPerdida extends StatefulWidget {
  final String mascotaId; // Id de la mascota seleccionada

  FormularioPerdida({required this.mascotaId});

  @override
  _FormularioPerdidaState createState() => _FormularioPerdidaState();
}

class _FormularioPerdidaState extends State<FormularioPerdida> {
  // Variables para almacenar la información del formulario
  late String horaPerdida;
  late String direccionPerdida;
  late String descripcionPerdida;

  bool agregarDireccionManualmente = false;

  LatLng? ubicacionSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Pérdida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complete el formulario de pérdida:'),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                horaPerdida = value;
              },
              decoration: InputDecoration(labelText: 'Hora de pérdida'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: agregarDireccionManualmente,
                  onChanged: (value) {
                    setState(() {
                      agregarDireccionManualmente = value!;
                    });
                  },
                ),
                Text('Agregar dirección manualmente'),
              ],
            ),
            if (!agregarDireccionManualmente)
              TextField(
                onChanged: (value) {
                  direccionPerdida = value;
                },
                decoration: InputDecoration(labelText: 'Dirección de pérdida'),
              ),
            if (agregarDireccionManualmente)
              ElevatedButton(
                onPressed: () {
                  _seleccionarDireccionEnMapa();
                },
                child: Text('Seleccionar dirección en el mapa'),
              ),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                descripcionPerdida = value;
              },
              decoration:
                  InputDecoration(labelText: 'Descripción de la pérdida'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _generarAlerta();
              },
              child: Text('Generar Alerta'),
            ),
          ],
        ),
      ),
    );
  }

  void _seleccionarDireccionEnMapa() async {
    // Abre la pantalla para seleccionar la ubicación en el mapa
    final LatLng? ubicacionSeleccionadaNueva = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionarUbicacionEnMapa(),
      ),
    );

    // Actualiza la ubicación seleccionada si se elige una nueva
    if (ubicacionSeleccionadaNueva != null) {
      setState(() {
        ubicacionSeleccionada = ubicacionSeleccionadaNueva;
      });
    }
  }

  void _generarAlerta() async {
    try {
      // Obtener la referencia de la mascota en Firestore
      DocumentReference mascotaRef = FirebaseFirestore.instance
          .collection('mascotas')
          .doc(widget.mascotaId);

      // Obtener la información actual de la mascota
      DocumentSnapshot mascotaSnapshot = await mascotaRef.get();
      if (mascotaSnapshot.exists) {
        // Verificar si la mascota ya está marcada como perdida
        if (mascotaSnapshot['perdida'] == true) {
          // Mostrar un mensaje indicando que la mascota ya está marcada como perdida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Esta mascota ya está marcada como perdida.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Actualizar la información de la mascota con el estado de "perdida" y la información del formulario
          await mascotaRef.update({
            'perdida': true,
            'horaPerdida': horaPerdida,
            'descripcionPerdida': descripcionPerdida,
            if (!agregarDireccionManualmente)
              'direccionPerdida': direccionPerdida,
            if (ubicacionSeleccionada != null)
              'ubicacionPerdida': {
                'latitude': ubicacionSeleccionada!.latitude,
                'longitude': ubicacionSeleccionada!.longitude,
              },
          });

          // Mostrar un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alerta generada correctamente.'),
              duration: Duration(seconds: 2),
            ),
          );

          // Navegar de nuevo a la página de MisMascotasPage
          Navigator.pop(context);
        }
      }
    } catch (error) {
      // Manejar errores
      print('Error al generar la alerta: $error');
    }
  }
}
