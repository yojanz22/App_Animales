import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapPage extends StatefulWidget {
  final LatLng initialPosition;

  GoogleMapPage({required this.initialPosition});

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Position? currentPosition;
  double radioSeleccionado = 200.0;
  String tipoSeleccionado = 'Todos';

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

      setState(() {
        currentPosition = position;
      });

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
      markers.clear();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('mascotas')
          .where('perdida', isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        if (document['ubicacionPerdida'] != null) {
          Map<String, dynamic> ubicacionPerdida = document['ubicacionPerdida'];
          double latitude = ubicacionPerdida['latitude'];
          double longitude = ubicacionPerdida['longitude'];

          double distancia = await Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            latitude,
            longitude,
          );

          if (distancia <= radioSeleccionado &&
              (tipoSeleccionado == 'Todos' ||
                  document['tipo'] == tipoSeleccionado)) {
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
      }

      setState(() {});
    } catch (e) {
      print('Error loading lost animals: $e');
    }
  }

  void _showAnimalDetailsPopup(
      BuildContext context, QueryDocumentSnapshot document) {
    // El código para mostrar los detalles del animal
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
              target: widget.initialPosition,
              zoom: 12.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: markers,
          ),
          Positioned(
            top: 8.0,
            left: 8.0,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      radioSeleccionado = 200.0;
                    });
                    _loadLostAnimals();
                  },
                  child: Text('200m'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      radioSeleccionado = 500.0;
                    });
                    _loadLostAnimals();
                  },
                  child: Text('500m'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      radioSeleccionado = double.infinity;
                    });
                    _loadLostAnimals();
                  },
                  child: Text('Ver Todos'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60.0,
            left: 8.0,
            child: DropdownButton<String>(
              value: tipoSeleccionado,
              onChanged: (value) {
                setState(() {
                  tipoSeleccionado = value!;
                });
                _loadLostAnimals();
              },
              items: [
                DropdownMenuItem(
                  value: 'Todos',
                  child: Text('Todos'),
                ),
                DropdownMenuItem(
                  value: 'Perro',
                  child: Text('Perro'),
                ),
                DropdownMenuItem(
                  value: 'Gato',
                  child: Text('Gato'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
