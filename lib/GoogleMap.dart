import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController mapController;

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
