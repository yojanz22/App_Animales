import 'package:flutter/material.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nombreActual;
  final String correoActual;

  EditarPerfilPage({required this.nombreActual, required this.correoActual});

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreActual;
    _correoController.text = widget.correoActual;
  }

  void _guardarCambios() {
    // Lógica para guardar los cambios en el perfil
    String nuevoNombre = _nombreController.text;
    String nuevoCorreo = _correoController.text;

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
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nuevo Nombre'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _correoController,
              decoration:
                  InputDecoration(labelText: 'Nuevo Correo Electrónico'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
