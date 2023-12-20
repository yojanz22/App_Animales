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
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _tipoMascota = 'Perro'; // Valor predeterminado

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  String?
      _imagePath; // Variable para almacenar la ruta de la imagen seleccionada

  bool _cargando = false; // Variable para controlar la pantalla de carga

  Future<void> _agregarMascota() async {
    try {
      // Validar el formulario
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _cargando = true; // Mostrar pantalla de carga
        });

        // Obtener al usuario actual
        User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          // Obtener el ID y nombre del usuario actual
          String userId = currentUser.uid;
          String userName = currentUser.displayName ?? '';

          // Subir imagen a Firebase Storage y obtener la URL
          String imageUrl = await _subirImagen(userId);

          // Agregar mascota a la base de datos con el nombre del dueño
          await _firestore.collection('mascotas').add({
            'nombre': _nombreMascotaController.text,
            'tipo': _tipoMascota,
            'raza': _razaController.text,
            'edad': _edadController.text,
            'peso': _pesoController.text,
            'descripcion': _descripcionController.text,
            'idUsuario': userId,
            'nombreUsuario':
                userName, // Asegúrate de que userName tenga el valor correcto
            'imagen': imageUrl,
            'perdida': false,
            // Otros campos de la mascota...
          });

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mascota agregada correctamente'),
              duration: Duration(seconds: 2),
            ),
          );

          // Limpiar campos después de agregar la mascota
          _limpiarCampos();
        } else {
          print('El usuario no está autenticado');
        }

        setState(() {
          _cargando = false; // Ocultar pantalla de carga
        });
      }
    } catch (e) {
      // Manejo de errores
      print('Error al agregar la mascota: $e');
      setState(() {
        _cargando = false; // Ocultar pantalla de carga en caso de error
      });
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

  void _limpiarCampos() {
    _nombreMascotaController.clear();
    _razaController.clear();
    _edadController.clear();
    _pesoController.clear();
    _descripcionController.clear();
    _tipoMascota = 'Perro'; // Restaurar tipo de mascota a valor predeterminado
    _imagePath = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota'),
      ),
      body: _cargando
          ? _buildPantallaCarga()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nombreMascotaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el nombre de la mascota';
                        }
                        return null;
                      },
                      decoration:
                          InputDecoration(labelText: 'Nombre de la Mascota'),
                    ),
                    SizedBox(height: 10),
                    // Selector de Tipo de Mascota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTipoMascotaButton('Perro'),
                        SizedBox(width: 10),
                        _buildTipoMascotaButton('Gato'),
                      ],
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
                      controller: _descripcionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese la descripción de la mascota';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Descripción'),
                    ),
                    SizedBox(height: 20),
                    // Botón para tomar o seleccionar foto
                    ElevatedButton(
                      onPressed: () async {
                        await _mostrarOpcionesFoto();
                      },
                      child: Text('Tomar o Seleccionar Foto'),
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

  Widget _buildTipoMascotaButton(String tipo) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _tipoMascota = tipo;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: _tipoMascota == tipo ? Colors.blue : null,
      ),
      child: Text(tipo),
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

  Widget _buildPantallaCarga() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
