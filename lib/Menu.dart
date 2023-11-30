import 'package:appanimales/EditarPerfil.dart';
import 'package:appanimales/GoogleMap.dart';
import 'package:appanimales/Mascotas.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _tabController = TabController(length: 2, vsync: this);

    cargarInformacionUsuario();
  }

  void cargarInformacionUsuario() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user?.uid)
          .get();
      if (userSnapshot.exists) {
        setState(() {
          nombreUsuario = userSnapshot['nombreUsuario'];
          nombreCompleto =
              userSnapshot['nombreCompleto'] ?? ''; // Agrega esta línea
          telefono = userSnapshot['telefono'] ?? '';
          direccion = userSnapshot['direccion'] ?? '';
        });
      }
    } catch (error) {
      print('Error al cargar la información del usuario: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal'),
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
        physics:
            NeverScrollableScrollPhysics(), // Esto deshabilita el deslizamiento
        children: [
          GoogleMapPage(),
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
          ],
        ),
      ),
    );
  }
}
