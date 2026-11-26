import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../identity/identity.dart'; // Para acceder a IdentityProvider y permitir cerrar sesión
import 'admin_products_screen.dart';
// import 'admin_ingredients_screen.dart';
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    final List<Widget> sections = [
      const _WarehouseSection(),
      const Center(child: Text('Sección Órdenes (siguiente paso)')),
      const Center(child: Text('Sección Finanzas (siguiente paso)')),
    ];

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
      body: IndexedStack(index: _currentIndex, children: sections),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Almacén',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Órdenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Finanzas',
          ),
        ],
      ),
      /*Center(
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
              SizedBox(height: 8),

              // Botón terciario para acceder a la gestión de ordenes
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.adminOrders);
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Gestionar Órdenes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // O el color de tu preferencia
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
              SizedBox(height: 8),

              // Cuarto boton para acceder a la gestión de finanzas
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.adminFinance);
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Gestionar Finanzas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // O el color de tu preferencia
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
      ),*/
    );
  }
}

class _WarehouseSection extends StatelessWidget {
  const _WarehouseSection();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          Material(
            color: Colors.white,
            elevation: 1,
            child: TabBar(
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(
                  icon: Icon(Icons.fastfood_rounded),
                  text: 'Productos',
                ),
                Tab(
                  icon: Icon(Icons.kitchen_rounded),
                  text: 'Ingredientes',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pestaña 1: Productos
                AdminProductsBody(),
                // Pestaña 2: Ingredientes
                Center(child: Text('Vista de Ingredientes')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
