import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class FormularioAdopcion extends StatefulWidget {
  @override
  _FormularioAdopcionState createState() => _FormularioAdopcionState();
}

class _FormularioAdopcionState extends State<FormularioAdopcion> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  bool _estaEsterilizado = false;

  String? _imagePath;

  Future<void> _tomarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error al seleccionar la foto: $e');
    }
  }

  Future<void> _guardarMascota() async {
    try {
      // Validar el formulario
      if (_formKey.currentState?.validate() ?? false) {
        // Subir la imagen a Firebase Storage
        String imageUrl = await _subirImagen();

        // Agregar la información de la mascota a Firestore
        await FirebaseFirestore.instance.collection('mascotas_adopcion').add({
          'nombre': _nombreController.text,
          'edad': _edadController.text,
          'peso': _pesoController.text,
          'raza': _razaController.text,
          'descripcion': _descripcionController.text,
          'estaEsterilizado': _estaEsterilizado,
          'imagenUrl': imageUrl,
          // Agregar más campos según sea necesario
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mascota en adopción agregada correctamente'),
            duration: Duration(seconds: 2),
          ),
        );

        // Limpiar campos después de agregar la mascota
        _limpiarCampos();
      }
    } catch (error) {
      // Manejo de errores
      print('Error al guardar la mascota: $error');
    }
  }

  Future<String> _subirImagen() async {
    try {
      // Obtener referencia al storage
      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(
                'imagenes_mascotas_adopcion/${DateTime.now().millisecondsSinceEpoch}.jpg',
              );

      // Subir la imagen
      await storageReference.putFile(File(_imagePath!));

      // Obtener la URL de la imagen
      String imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      // Manejo de errores
      print('Error al subir la imagen: $e');
      return '';
    }
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _edadController.clear();
    _pesoController.clear();
    _razaController.clear();
    _descripcionController.clear();
    _estaEsterilizado = false;
    _imagePath = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota en Adopción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre de la mascota';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _edadController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la edad de la mascota';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Edad'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _pesoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el peso de la mascota';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Peso'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _razaController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la raza de la mascota';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Raza'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descripcionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la descripción de la mascota';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _estaEsterilizado,
                    onChanged: (value) {
                      setState(() {
                        _estaEsterilizado = value ?? false;
                      });
                    },
                  ),
                  Text('¿Está esterilizado?'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _mostrarOpcionesFoto();
                },
                child: Text('Tomar o Seleccionar Foto'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _guardarMascota();
                },
                child: Text('Guardar Mascota en Adopción'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarOpcionesFoto() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Fuente de Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _tomarFoto();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Foto cargada correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('Tomar Foto'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _seleccionarFoto();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Foto cargada correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('Seleccionar desde Galería'),
              ),
            ],
          ),
        );
      },
    );
  }
}
