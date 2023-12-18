import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class FormularioAdopcion extends StatefulWidget {
  @override
  _FormularioAdopcionState createState() => _FormularioAdopcionState();
}

class _FormularioAdopcionState extends State<FormularioAdopcion> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  String _tipoEdad = 'Días';
  String _tipoPeso = 'Kilogramos';
  bool _esterilizado = false;
  bool _noSabeEsterilizado = false;

  List<File> _imagenes = [];
  final ImagePicker _imagePicker = ImagePicker();

  void _guardarInformacion() async {
    try {
      // Obtener una referencia a la colección 'animales_adopcion' en Firestore
      CollectionReference animalesAdopcionCollection =
          FirebaseFirestore.instance.collection('animales_adopcion');

      // Subir imágenes a Firebase Storage y obtener las URLs
      List<String> urls = await _subirImagenes();

      // Agregar la información a Firestore en la colección 'animales_adopcion'
      await animalesAdopcionCollection.add({
        'nombre': _nombreController.text,
        'edad': _edadController.text,
        'tipoEdad': _tipoEdad,
        'peso': _pesoController.text,
        'tipoPeso': _tipoPeso,
        'esterilizado': _esterilizado,
        'noSabeEsterilizado': _noSabeEsterilizado,
        'imagenes': urls,
        // Otros campos que desees agregar...
      });

      // Mensaje de éxito
      print(
          'Información guardada correctamente en la colección animales_adopcion.');

      // Limpiar campos después de guardar la información
      _limpiarCampos();
    } catch (e) {
      // Manejo de errores
      print(
          'Error al guardar la información en la colección animales_adopcion: $e');
    }
  }

  Future<List<String>> _subirImagenes() async {
    List<String> urls = [];

    for (File imagen in _imagenes) {
      try {
        // Obtener referencia al storage
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('imagenes_adopcion')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Subir la imagen
        await storageReference.putFile(imagen);

        // Obtener la URL de la imagen
        String imageUrl = await storageReference.getDownloadURL();
        urls.add(imageUrl);
      } catch (e) {
        // Manejo de errores al subir imágenes
        print('Error al subir la imagen: $e');
      }
    }

    return urls;
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagenes.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  Future<void> _seleccionarFotos() async {
    try {
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 70,
      );

      if (pickedFiles != null) {
        setState(() {
          _imagenes.addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    } catch (e) {
      print('Error al seleccionar las fotos: $e');
    }
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _edadController.clear();
    _pesoController.clear();
    _tipoEdad = 'Días';
    _tipoPeso = 'Kilogramos';
    _esterilizado = false;
    _noSabeEsterilizado = false;
    _imagenes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Adopción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complete el formulario de adopción:'),
            SizedBox(height: 10),
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Edad'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _tipoEdad,
                    onChanged: (value) {
                      setState(() {
                        _tipoEdad = value!;
                      });
                    },
                    items: ['Días', 'Semanas', 'Años']
                        .map((tipo) => DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Peso'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _tipoPeso,
                    onChanged: (value) {
                      setState(() {
                        _tipoPeso = value!;
                      });
                    },
                    items: ['Kilogramos', 'Gramos']
                        .map((tipo) => DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _esterilizado,
                  onChanged: (value) {
                    setState(() {
                      _esterilizado = value!;
                    });
                  },
                ),
                Text('¿Está esterilizado?'),
                SizedBox(width: 10),
                Checkbox(
                  value: _noSabeEsterilizado,
                  onChanged: (value) {
                    setState(() {
                      _noSabeEsterilizado = value!;
                      if (value!) {
                        _esterilizado =
                            false; // Desmarcar el checkbox principal si se selecciona "No lo sé"
                      }
                    });
                  },
                ),
                Text('No lo sé'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _mostrarOpcionesFoto();
              },
              child: Text('Tomar o Seleccionar Fotos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarInformacion,
              child: Text('Guardar Información'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarOpcionesFoto() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Fuente de Fotos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _tomarFoto();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fotos cargadas correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text('Tomar Foto'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _seleccionarFotos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fotos cargadas correctamente'),
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
