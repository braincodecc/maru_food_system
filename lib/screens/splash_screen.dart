import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Mostrar splash por 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navegar SOLO al AuthWrapper
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Maru Food',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text('Gestión de comida rápida'),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuario autenticado
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Usuario no autenticado
        return const LoginScreen();
      },
    );
  }
}
