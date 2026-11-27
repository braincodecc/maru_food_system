import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../identity/identity.dart';
import 'admin_products_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_ingredients_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_menu_screen.dart';

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
      const _SalesSection(),
      const _FinanceSection(),
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
            icon: Icon(Icons.inventory),
            label: 'Almacén',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Finanzas',
          ),
        ],
      ),
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
                Tab(icon: Icon(Icons.fastfood_rounded), text: 'Productos'),
                Tab(icon: Icon(Icons.kitchen_rounded), text: 'Ingredientes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pestaña 1: Productos
                AdminProductsBody(),
                // Pestaña 2: Ingredientes
                AdminIngredientsBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesSection extends StatelessWidget {
  const _SalesSection();
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
                Tab(icon: Icon(Icons.menu_book), text: 'Menú'),
                Tab(icon: Icon(Icons.receipt_long), text: 'Ordenes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                AdminMenuBody(),
                AdminOrdersBody(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceSection extends StatelessWidget {
  const _FinanceSection();

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
                  icon: Icon(Icons.account_balance_rounded),
                  text: 'Balances de cuenta',
                ),
                Tab(
                  icon: Icon(Icons.history_rounded),
                  text: 'Historial de transacciones',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pestaña 1: Productos
                AdminFinanceBody(),
                // Pestaña 2: Ingredientes
                Center(child: Text('Vista de transacciones')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
