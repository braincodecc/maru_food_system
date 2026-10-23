import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: "eribeckbermudez@gmail.com");
  final _passwordController = TextEditingController(text: "123456");
  bool _loading = false;

  Future<void> login() async {
    try {
      setState(() => _loading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navegar al Home Screen después del login
      //Navigator.pushReplacementNamed(context, "/home");

    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();//"Error al iniciar sesión";

      if (e.code == "user-not-found") {
        error = "No existe un usuario con ese correo";
      } else if (e.code == "wrong-password") {
        error = "Contraseña incorrecta";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Maru Food System",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: login,
                  child: const Text("Iniciar sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
