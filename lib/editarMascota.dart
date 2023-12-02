import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarMascotaPage extends StatefulWidget {
  final DocumentSnapshot mascota;

  EditarMascotaPage({required this.mascota});

  @override
  _EditarMascotaPageState createState() => _EditarMascotaPageState();
}

class _EditarMascotaPageState extends State<EditarMascotaPage> {
  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _razaController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;
  late TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.mascota['nombre']);
    _tipoController = TextEditingController(text: widget.mascota['tipo']);
    _razaController = TextEditingController(text: widget.mascota['raza']);
    _edadController = TextEditingController(text: widget.mascota['edad']);
    _pesoController = TextEditingController(text: widget.mascota['peso']);
    _descripcionController =
        TextEditingController(text: widget.mascota['descripcion']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Mascota'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navegar de regreso a la página anterior
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _tipoController,
                decoration: InputDecoration(labelText: 'Tipo de Mascota'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _razaController,
                decoration: InputDecoration(labelText: 'Raza'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(labelText: 'Edad'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(labelText: 'Peso'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica para guardar los cambios en la base de datos
                  _guardarCambios();
                },
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarCambios() async {
    try {
      await widget.mascota.reference.update({
        'nombre': _nombreController.text,
        'tipo': _tipoController.text,
        'raza': _razaController.text,
        'edad': _edadController.text,
        'peso': _pesoController.text,
        'descripcion': _descripcionController.text,
        // Agrega más campos según sea necesario
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cambios guardados correctamente'),
          duration: Duration(seconds: 2),
        ),
      );

      // Puedes agregar lógica para navegar de regreso a la lista de mascotas
      Navigator.pop(context);
    } catch (e) {
      // Manejo de errores
      print('Error al guardar cambios: $e');
    }
  }
}
