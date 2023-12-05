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
  double latitud = -33.0246; // Latitud de Viña del Mar, Chile
  double longitud = -71.5519; // Longitud de Viña del Mar, Chile

  Set<Marker> markers = {}; // Lista de marcadores

  @override
  void initState() {
    super.initState();
    _centrarEnUbicacionActual();
  }

  Future<void> _centrarEnUbicacionActual() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
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
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(latitud, longitud),
              zoom: 16.0,
            ),
            onTap: _agregarTarjetaUbicacion,
            markers: markers,
            myLocationEnabled: true, // Activar la ubicación del usuario
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _mostrarConfirmacion();
                  },
                  child: Text('Confirmar Ubicación'),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _agregarTarjetaUbicacion(LatLng ubicacion) {
    setState(() {
      markers.clear(); // Limpiar marcadores previos
      markers.add(
        Marker(
          markerId: MarkerId('ubicacionSeleccionada'),
          position: ubicacion,
          infoWindow: InfoWindow(
            title: 'Ubicación Seleccionada',
            snippet: 'Arrastra para ajustar',
          ),
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(ubicacion));
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
      if (result != null) {
        // Navegar a la página de FormularioPerdida con la ubicación seleccionada
        Navigator.pop(context, result);
      }
    });
  }
}
