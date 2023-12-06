import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsPage extends StatefulWidget {
  final String chatId;

  ChatsPage({required this.chatId});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder(
      stream: _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var messages = snapshot.data!.docs;

        List<Widget> messageWidgets = [];
        for (var message in messages) {
          var messageText = message['text'];
          var messageSender = message['sender'];

          var messageWidget = _buildMessageWidget(messageSender, messageText);
          messageWidgets.add(messageWidget);
        }

        return ListView(
          children: messageWidgets,
        );
      },
    );
  }

  Widget _buildMessageWidget(String sender, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            sender == 'yo' ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sender == 'yo' ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              _sendMessage();
            },
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    var text = _messageController.text;
    if (text.isNotEmpty) {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': text,
        'sender': 'yo',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Limpiar el campo de entrada después de enviar el mensaje
      _messageController.clear();
    }
  }
}
