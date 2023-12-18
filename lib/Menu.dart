import 'package:appanimales/AdopcionLista.dart';
import 'package:appanimales/FormularioAdopcion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appanimales/EditarPerfil.dart';
import 'package:appanimales/buzon.dart';
import 'package:appanimales/AgregarMascota.dart';
import 'package:appanimales/MisMascotas.dart';
import 'package:appanimales/GoogleMap.dart';
import 'package:appanimales/Mascotas.dart';

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
    _tabController = TabController(length: 2, vsync: this)..addListener(() {});
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

        if (data.containsKey('nombreUsuario')) {
          setState(() {
            nombreUsuario = data['nombreUsuario'];
            nombreCompleto = data['nombreCompleto'] ?? '';
            telefono = data['telefono'] ?? '';
            direccion = data['direccion'] ?? '';
          });
        } else {
          // Manejar el caso cuando el campo 'nombreUsuario' no está presente
          print('El campo "nombreUsuario" no está presente en el documento.');
        }
      } else {
        // Manejar el caso cuando el documento no existe
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
      // Si los permisos están otorgados, obtén la ubicación actual
      _getCurrentLocation();
    } else {
      // Si los permisos no están otorgados, solicita la autorización al usuario
      var result = await Permission.location.request();
      if (result.isGranted) {
        // Si el usuario otorga permisos, obtén la ubicación actual
        _getCurrentLocation();
      } else {
        // Maneja el caso en el que el usuario no otorga permisos
        print('El usuario no otorgó permisos de ubicación.');
      }
    }
  }

  _checkAndRequestNotificationPermissions() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      // Si los permisos de notificación no están otorgados, solicita la autorización al usuario
      await Permission.notification.request();
    }
  }

  _getCurrentLocation() async {
    // Código para obtener la ubicación actual
    // ...
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
            Tab(text: 'Google Map'),
            Tab(text: 'Mascotas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          GoogleMapPage(initialPosition: LatLng(-33.0458, -71.6197)),
          MascotasPage(),
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
              title: Text('Ir a Buzón'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuzonPage(),
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
                    builder: (context) =>
                        FormularioAdopcion(), // Agrega el formulario de adopción aquí
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Lista Adopcion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListaAnimalesAdopcion(), // Agrega el formulario de adopción aquí
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
