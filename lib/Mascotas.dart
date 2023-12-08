import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MascotasPage extends StatefulWidget {
  @override
  _MascotasPageState createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  List<String> tiposAnimales = ['Todos', 'Perro', 'Gato'];
  String tipoSeleccionado = 'Todos';
  DateTime? fechaSeleccionada;

  void _mostrarMenuFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFiltroTipoAnimal(),
              _buildFiltroFecha(),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _limpiarFiltros();
                      Navigator.pop(context);
                    },
                    child: Text('Limpiar Filtros'),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _aplicarFiltros();
                      Navigator.pop(context);
                    },
                    child: Text('Aplicar Filtros'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltroTipoAnimal() {
    return DropdownButton<String>(
      value: tipoSeleccionado,
      items: tiposAnimales.map((tipo) {
        return DropdownMenuItem<String>(
          value: tipo,
          child: Text(tipo),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          tipoSeleccionado = value!;
        });
      },
    );
  }

  Widget _buildFiltroFecha() {
    return Row(
      children: [
        Text('Fecha de Pérdida: '),
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null && pickedDate != fechaSeleccionada) {
              setState(() {
                fechaSeleccionada = pickedDate;
              });
            }
          },
          child: Text(
            fechaSeleccionada != null
                ? '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}'
                : 'Seleccione',
          ),
        ),
      ],
    );
  }

  void _limpiarFiltros() {
    setState(() {
      tipoSeleccionado = 'Todos';
      fechaSeleccionada = null;
    });
  }

  void _aplicarFiltros() {
    // Implementa la lógica para aplicar los filtros a tu consulta Firestore
    // Consulta Firestore con los filtros seleccionados (tipoSeleccionado, distancia, fecha, hora).
    // Puedes usar estos valores en la consulta Firestore para filtrar los resultados.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animales Perdidos'),
        actions: [
          IconButton(
            onPressed: () {
              _mostrarMenuFiltros(context);
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _buildPerdidosList(),
    );
  }

  Widget _buildPerdidosList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('mascotas')
          .where('perdida', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var mascotasPerdidas = snapshot.data?.docs;
        return ListView.builder(
          itemCount: mascotasPerdidas!.length,
          itemBuilder: (context, index) {
            var mascota = mascotasPerdidas[index].data();
            var nombre =
                mascota?['nombre'] as String? ?? 'Nombre no disponible';
            var tipo = mascota?['tipo'] as String? ?? 'Tipo no disponible';
            var ultimaUbicacion = mascota?['ultimaDireccionVista'] as String? ??
                'Ubicación no disponible';
            var horaPerdida =
                mascota?['horaPerdida'] as String? ?? 'Hora no disponible';
            var fechaPerdida =
                mascota?['fechaPerdida'] as String? ?? 'Fecha no disponible';
            var descripcion = mascota?['descripcion'] as String? ??
                'Descripción no disponible';
            var imageUrl = mascota?['imagen'] as String? ?? '';

            // Aplicar filtros
            if (tipoSeleccionado != 'Todos' && tipoSeleccionado != tipo) {
              return Container(); // Si el tipo no coincide, no mostramos el elemento
            }

            if (fechaSeleccionada != null) {
              // Convierte la fecha almacenada en Firestore a DateTime
              DateTime fechaMascota = DateTime.parse(fechaPerdida);
              if (fechaMascota != fechaSeleccionada) {
                return Container(); // Si la fecha no coincide, no mostramos el elemento
              }
            }

            return _buildMascotaPerdidaCard(
              nombre,
              ultimaUbicacion,
              horaPerdida,
              fechaPerdida,
              descripcion,
              imageUrl,
              context,
              mascotasPerdidas[index],
            );
          },
        );
      },
    );
  }

  Widget _buildMascotaPerdidaCard(
    String nombre,
    String ultimaUbicacion,
    String horaPerdida,
    String fechaPerdida,
    String descripcion,
    String imageUrl,
    BuildContext context,
    DocumentSnapshot mascota,
  ) {
    bool tieneRecompensa = mascota['recompensa'] != null;
    double recompensa =
        tieneRecompensa ? (mascota['recompensa'] as num).toDouble() : 0.0;

    return Card(
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        title: Text(nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ultimaUbicacion),
            Text('Hora de pérdida: $horaPerdida'),
            Text('Fecha de pérdida: $fechaPerdida'),
            Text('Descripción: $descripcion'),
            if (tieneRecompensa)
              Container(
                color: Colors.amber,
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(width: 5),
                    Text('Recompensa: \$${recompensa.toString()}'),
                  ],
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesAnimalesPerdidos(
                ubicacionPerdida: mascota[
                    'ubicacionPerdida'], // Proporciona el nombre correcto del campo de tu Firestore
                nombre: nombre,
                ultimaUbicacion: ultimaUbicacion,
                horaPerdida: horaPerdida,
                fechaPerdida: fechaPerdida,
                descripcion: descripcion,
                imageUrl: imageUrl,
                recompensa: recompensa,
              ),
            ),
          );
        },
      ),
    );
  }
}
