import 'package:appanimales/chats.dart';
import 'package:flutter/material.dart';
import 'message_model.dart'; // Importa el modelo de mensaje

class BuzonPage extends StatelessWidget {
  final List<Message> mensajes = [
    Message(sender: 'Usuario 1', text: 'Hola, ¿cómo estás?'),
    Message(
        sender: 'Usuario 2', text: 'Recuerda comprar comida para la mascota.'),
    Message(sender: 'Usuario 1', text: '¿Cuándo podemos encontrarnos?'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buzón de Mensajes'),
      ),
      body: _buildBuzonList(context),
    );
  }

  Widget _buildBuzonList(BuildContext context) {
    return ListView.builder(
      itemCount: mensajes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _navigateToChats(context, mensajes[index]);
          },
          child: ListTile(
            title: Text('${mensajes[index].sender}: ${mensajes[index].text}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _eliminarMensaje(context, index);
              },
            ),
          ),
        );
      },
    );
  }

  void _eliminarMensaje(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mensaje eliminado'),
      ),
    );

    mensajes.removeAt(index);
  }

  void _navigateToChats(BuildContext context, Message mensaje) {
    // Puedes pasar la información del mensaje a la página de chats.dart si es necesario
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsPage(chatId: 'tuChatIdAqui'),
      ),
    );
  }
}
