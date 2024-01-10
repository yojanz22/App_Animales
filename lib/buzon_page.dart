import 'package:flutter/material.dart';

class BuzonPage extends StatefulWidget {
  final String nombreUsuario;

  BuzonPage({required this.nombreUsuario});

  @override
  _BuzonPageState createState() => _BuzonPageState();
}

class _BuzonPageState extends State<BuzonPage> {
  // Lógica del buzón de mensajes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buzón de Mensajes'),
      ),
      body: Center(
        child: Text('Aquí irá la interfaz del buzón de mensajes'),
      ),
    );
  }
}
