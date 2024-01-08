import 'package:appanimales/AdopcionLista.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AgregarMascota.dart';
import 'EditarPerfil.dart';
import 'FormularioAdopcion.dart';
import 'GoogleMap.dart';
import 'Mascotas.dart';
import 'MiAdopcionLista.dart';
import 'MisMascotas.dart';

class MenuPage extends StatefulWidget {
  final User? user;

  MenuPage({required this.user});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String nombreUsuario = '';
  String telefono = '';
  String direccion = '';
  String nombreCompleto = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)..addListener(() {});
    cargarInformacionUsuario();
    _checkAndRequestPermissions();
  }

  void cargarInformacionUsuario() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user?.uid)
          .get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;

        print('Información del usuario: $data');

        if (data.containsKey('nombreUsuario')) {
          setState(() {
            nombreUsuario = data['nombreUsuario'];
            nombreCompleto = data['nombreCompleto'] ?? '';
            telefono = data['telefono'] ?? '';
            direccion = data['direccion'] ?? '';
          });
        } else {
          print('El campo "nombreUsuario" no está presente en el documento.');
        }
      } else {
        print('El documento no existe.');
      }
    } catch (error) {
      print('Error al cargar la información del usuario: $error');
    }
  }

  _checkAndRequestPermissions() async {
    await _checkAndRequestLocationPermissions();
    await _checkAndRequestNotificationPermissions();
  }

  _checkAndRequestLocationPermissions() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        _getCurrentLocation();
      } else {
        print('El usuario no otorgó permisos de ubicación.');
      }
    }
  }

  _checkAndRequestNotificationPermissions() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  _getCurrentLocation() async {
    // Código para obtener la ubicación actual
    // ...
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return GoogleMapPage(initialPosition: LatLng(-33.0458, -71.6197));
      case 1:
        return MascotasPage();
      case 2:
        return ListaAnimalesAdopcion();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Menú Principal'),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MisMascotasPage(seleccionarPerdida: true),
                  ),
                );
              },
              child: Text('Perdí mi Mascota'),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Mapa'),
            Tab(text: 'Mascotas Perdidas'),
            Tab(text: 'Lista Adopcion'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildPage(0),
          _buildPage(1),
          _buildPage(2),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido,',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    nombreUsuario,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarPerfilPage(
                      nombreUsuarioActual: nombreUsuario,
                      nombreCompletoActual: nombreCompleto,
                      correoActual: widget.user?.email ?? '',
                      telefonoActual: telefono,
                      direccionActual: direccion,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Agregar Mascota'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarMascotaPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Ver mis mascotas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MisMascotasPage(seleccionarPerdida: false),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Agregar Mascota en Adopción'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormularioAdopcion(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Mi Lista Adopcion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MiAdopcionLista(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Perdí mi Mascota'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MisMascotasPage(seleccionarPerdida: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
