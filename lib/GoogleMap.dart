import 'package:appanimales/DetallesAnimalesPerdios.dart';
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

          if (distancia <= radioSeleccionado) {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document['nombre'] ?? 'Animal Perdido',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Image.network(
                  document['imagen'] ?? '',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10.0),
                Text('Descripción: ${document['descripcion'] ?? ''}'),
                Text('Edad: ${document['edad'] ?? ''}'),
                Text('Fecha de Pérdida: ${document['fechaPerdida'] ?? ''}'),
                Text('Hora de Pérdida: ${document['horaPerdida'] ?? ''}'),
                Text('Raza: ${document['raza'] ?? ''}'),
                Text('Peso: ${document['peso'] ?? ''}'),
                Text('Tipo: ${document['tipo'] ?? ''}'),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToDetailsPage(document);
                  },
                  child: Text('Ver Detalles'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetailsPage(QueryDocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesAnimalesPerdidos(
          ubicacionPerdida: document['ubicacionPerdida'],
          nombre: document['nombre'] ?? '',
          horaPerdida: document['horaPerdida'] ?? '',
          fechaPerdida: document['fechaPerdida'] ?? '',
          descripcion: document['descripcion'] ?? '',
          imageUrl: document['imagen'] ?? '',
          recompensa: document['recompensa']?.toDouble(),
        ),
      ),
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
        ],
      ),
    );
  }
}
