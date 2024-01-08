import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String nombreDueno;

  ChatPage({required this.nombreDueno});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _mensajeController = TextEditingController();
  List<String> _mensajes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.nombreDueno}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_mensajes[index]),
                );
              },
            ),
          ),
          _buildEnviarMensaje(),
        ],
      ),
    );
  }

  Widget _buildEnviarMensaje() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensajeController,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _enviarMensaje();
            },
          ),
        ],
      ),
    );
  }

  void _enviarMensaje() {
    String mensaje = _mensajeController.text;
    if (mensaje.isNotEmpty) {
      setState(() {
        _mensajes.add('Yo: $mensaje');
      });
      _mensajeController.clear();
      // Aquí puedes implementar la lógica para enviar el mensaje al dueño
    }
  }
}
