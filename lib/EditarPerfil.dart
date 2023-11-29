import 'package:flutter/material.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nombreActual;
  final String correoActual;
  final String nombreUsuarioActual;
  final String telefonoActual;
  final String direccionActual;

  EditarPerfilPage({
    required this.nombreActual,
    required this.correoActual,
    required this.nombreUsuarioActual,
    required this.telefonoActual,
    required this.direccionActual,
  });

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _correoController = TextEditingController(text: widget.correoActual);
    _telefonoController = TextEditingController(text: widget.telefonoActual);
    _direccionController = TextEditingController(text: widget.direccionActual);
    _passwordController = TextEditingController();
  }

  void _actualizarPerfil() {
    // Lógica para actualizar el perfil
    String nuevoCorreo = _correoController.text;
    String nuevoTelefono = _telefonoController.text;
    String nuevaDireccion = _direccionController.text;

    // Aquí puedes realizar operaciones como actualizar la información en Firestore
    // o cualquier otro lugar donde almacenes los datos del usuario.

    // Una vez que hayas guardado los cambios, puedes navegar de nuevo a la página de Menú
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _correoController,
              decoration:
                  InputDecoration(labelText: 'Nuevo Correo Electrónico'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _telefonoController,
              decoration:
                  InputDecoration(labelText: 'Nuevo Número de Teléfono'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(labelText: 'Nueva Dirección'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _actualizarPerfil,
              child: Text('Actualizar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
