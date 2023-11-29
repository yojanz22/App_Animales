import 'package:appanimales/LoginPage.dart';
import 'package:appanimales/Menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Presentation extends StatefulWidget {
  @override
  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 300)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_animationController);

    // Inicia la animación y luego navega a la página de inicio de sesión al finalizar
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Gracias por elegir nuestra app',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Agregar esta parte para navegar a la LoginPage cuando la animación se completa
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Verificar si hay un usuario autenticado
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Si hay un usuario autenticado, navega a la página principal
          // Aquí debes reemplazar `MainPage` con la página principal real de tu aplicación
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MenuPage(user: user)),
          );
        } else {
          // Si no hay un usuario autenticado, navega a la página de inicio de sesión
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    });
  }
}
