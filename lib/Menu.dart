// menu_page.dart

import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido al Menú!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Agrega la lógica para lo que quieres hacer cuando se presiona este botón
              },
              child: Text('Botón 1'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Agrega la lógica para lo que quieres hacer cuando se presiona este botón
              },
              child: Text('Botón 2'),
            ),
          ],
        ),
      ),
    );
  }
}
