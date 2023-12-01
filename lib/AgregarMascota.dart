import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AgregarMascotaPage extends StatefulWidget {
  @override
  _AgregarMascotaPageState createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  final TextEditingController _nombreMascotaController =
      TextEditingController();
  final TextEditingController _tipoMascotaController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  String?
      _imagePath; // Variable para almacenar la ruta de la imagen seleccionada

  Future<void> _agregarMascota() async {
    try {
      // Validar el formulario
      if (_formKey.currentState?.validate() ?? false) {
        // Obtener al usuario actual
        User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          // Obtener el ID del usuario actual
          String userId = currentUser.uid;

          // Subir imagen a Firebase Storage y obtener la URL
          String imageUrl = await _subirImagen(userId);

          // Agregar mascota a la base de datos con la URL de la imagen
          await _firestore.collection('mascotas').add({
            'nombre': _nombreMascotaController.text,
            'tipo': _tipoMascotaController.text,
            'raza': _razaController.text,
            'edad': _edadController.text,
            'peso': _pesoController.text,
            'descripcion': _descripcionController.text,
            'idUsuario': userId,
            'imagen': imageUrl,
            // Otros campos de la mascota...
          });

          // Mensaje de confirmación
          print('Mascota agregada con éxito.');
        }
      }
    } catch (e) {
      // Manejo de errores
      print('Error al agregar la mascota: $e');
    }
  }

  Future<String> _subirImagen(String userId) async {
    try {
      // Obtener referencia al storage
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('imagenes_mascotas')
          .child('$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

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

  Future<void> _tomarFoto() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nombreMascotaController,
                decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _tipoMascotaController,
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
              // Botones para tomar y seleccionar fotos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _tomarFoto();
                    },
                    child: Text('Tomar Foto'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Lógica para seleccionar la foto
                    },
                    child: Text('Seleccionar Foto'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarMascota,
                child: Text('Agregar Mascota'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
