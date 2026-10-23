import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../identity.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Los controllers declarados en el State para que vivan durante todo el ciclo de vida de la pantalla
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "eribeckbermudez@gmail.com");
    _passwordController = TextEditingController(text: "123456");
  }

  @override
  void dispose() {
    // 2. Liberar memoria cuando la pantalla se destruya
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reconstruir la UI cuando cambie el estado (ej. isLoading)
    final identityProvider = context.watch<IdentityProvider>();
    final emailController = TextEditingController(
      text: "eribeckbermudez@gmail.com",
    );
    final passwordController = TextEditingController(text: "123456");

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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                identityProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          // Usamos context.read para invocar acciones sin escuchar cambios
                          context.read<IdentityProvider>().login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                        },
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
