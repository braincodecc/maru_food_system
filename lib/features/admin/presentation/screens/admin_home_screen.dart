import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../identity/identity.dart'; // Para acceder a IdentityProvider y permitir cerrar sesión

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maru Food - Admin'),
        automaticallyImplyLeading:
            false, // Evita botón de retroceso por ser pantalla raíz
        actions: [
          // Botón directo para cerrar sesión desde el AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              // AuthWrapper redirigirá automáticamente al Login
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                size: 80,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Panel de Control, Admin!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestiona el inventario, revisa las alertas de stock y mantén al día el menú de Maru Food.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Botón principal para acceder a la gestión de productos
              ElevatedButton.icon(
                onPressed: () {
                  // Navegamos al dashboard de productos mediante la ruta global
                  Navigator.pushNamed(
                    context,
                    AppRoutes.adminDashboardProducts,
                  );
                },
                icon: const Icon(Icons.inventory_2),
                label: const Text('Gestionar Productos e Inventario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
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
              const SizedBox(height: 8),

              // Botón secundario para acceder a la gestión de ingredientes
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.adminIngredients);
                },
                icon: const Icon(Icons.kitchen),
                label: const Text('Gestionar Almacén / Ingredientes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // O el color de tu preferencia
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
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
