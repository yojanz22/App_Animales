import 'package:appanimales/Menu.dart';
import 'package:appanimales/firebase_options.dart';
import 'package:appanimales/presentation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Verifica si el usuario está autenticado
    // Puedes cambiar esta lógica según tus necesidades
    User? currentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: currentUser != null ? MenuPage(user: currentUser) : Presentation(),
    );
  }
}
