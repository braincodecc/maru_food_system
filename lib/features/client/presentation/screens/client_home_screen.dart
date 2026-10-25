import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart'; // Importa tus rutas globales

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maru Food - Inicio'),
        automaticallyImplyLeading:
            false, // Evita botón de retroceso en la pantalla raíz del rol
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fastfood_rounded,
                size: 80,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Bienvenido a Maru Food!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Disfruta de nuestras mejores hamburguesas, salchipapas y antojos preparados al momento.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Botón principal que dirige al catálogo/menú de productos
              ElevatedButton.icon(
                onPressed: () {
                  // Navegamos al menú utilizando la ruta nombrada centralizada
                  Navigator.pushNamed(context, AppRoutes.clientMenu);
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Ver Menú y Comprar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
