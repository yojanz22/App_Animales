import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SeleccionarUbicacionEnMapa extends StatefulWidget {
  @override
  _SeleccionarUbicacionEnMapaState createState() =>
      _SeleccionarUbicacionEnMapaState();
}

class _SeleccionarUbicacionEnMapaState
    extends State<SeleccionarUbicacionEnMapa> {
  GoogleMapController? mapController;
  double latitud = 0.0;
  double longitud = 0.0;

  @override
  void initState() {
    super.initState();
    _centrarEnUbicacionActual();
  }

  Future<void> _centrarEnUbicacionActual() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitud = position.latitude;
        longitud = position.longitude;
      });
    } catch (e) {
      print('Error al obtener la ubicación actual: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicación en el Mapa'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitud, longitud),
          zoom: 16.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('ubicacionSeleccionada'),
            position: LatLng(latitud, longitud),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarConfirmacion();
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _mostrarConfirmacion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Ubicación'),
          content: Text('¿Es esta la ubicación que deseas?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, LatLng(latitud, longitud));
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    ).then((result) {
      // Navegar de nuevo a FormularioPerdida con la ubicación seleccionada
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
  }
}
