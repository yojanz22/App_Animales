import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con el Dueño'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data?.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages!.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data();
                    var sender = message['sender'] ?? 'Usuario';

                    return ListTile(
                      title: Text('$sender: ${message['text']}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        InputDecoration(hintText: 'Escribe un mensaje...'),
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
          ),
        ],
      ),
    );
  }

  void _enviarMensaje() {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': messageText,
        'sender':
            'Usuario Actual', // Puedes obtener el nombre del usuario actual
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Limpiar el campo de texto después de enviar el mensaje
      _messageController.clear();
    }
  }
}
