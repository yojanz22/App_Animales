import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermissions();
  }

  _checkAndRequestLocationPermissions() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      await Permission.location.request();
    }
  }

  _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Cargar animales perdidos al obtener la ubicación actual
      await _loadLostAnimals();

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );
    } catch (e) {
      print('Error obtaining location: $e');
    }
  }

  _loadLostAnimals() async {
    try {
      // Recuperar animales perdidos de Firebase
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('mascotas')
          .where('perdida', isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        // Asegúrate de que la ubicacionPerdida esté presente en el documento
        if (document['ubicacionPerdida'] != null) {
          Map<String, dynamic> ubicacionPerdida = document['ubicacionPerdida'];
          double latitude = ubicacionPerdida['latitude'];
          double longitude = ubicacionPerdida['longitude'];

          markers.add(
            Marker(
              markerId: MarkerId(document.id),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: document['nombre'] ?? 'Animal Perdido',
                snippet: document['descripcionPerdida'] ?? '',
                onTap: () {
                  _showAnimalDetailsPopup(context, document);
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );
        }
      }

      // Actualizar el estado para que se vuelva a dibujar el mapa con los nuevos marcadores
      setState(() {});
    } catch (e) {
      print('Error loading lost animals: $e');
    }
  }

  void _showAnimalDetailsPopup(
      BuildContext context, QueryDocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(document['nombre'] ?? 'Animal Perdido'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                document['imagen'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text('Última Ubicación: ${document['ultimaDireccionVista']}'),
              Text('Hora de Pérdida: ${document['horaPerdida']}'),
              Text('Descripción: ${document['descripcionPerdida']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetallesAnimalesPerdidos(
                      nombre: document['nombre'],
                      ultimaUbicacion: document['ultimaDireccionVista'],
                      horaPerdida: document['horaPerdida'],
                      descripcion: document['descripcionPerdida'],
                      imageUrl: document['imagen'],
                      recompensa: document['recompensa'] != null
                          ? document['recompensa'].toDouble()
                          : null,
                      fechaPerdida: document['fechaPerdida'],
                    ),
                  ),
                );
              },
              child: Text('Ver Más'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  -33.0458, -71.6197), // Coordenadas de Viña del Mar, Chile
              zoom: 12.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            markers: markers,
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _checkAndRequestLocationPermissions,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
