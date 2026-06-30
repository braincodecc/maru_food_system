import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/orders_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Maru Food System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/exchange-rate'),
          ),
        ],
      ),

      // Botón principal de venta rápida
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange.shade800,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('VENDER AHORA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: () => Navigator.pushNamed(context, '/products'),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 20),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildSectionTitle('Gestión Operativa'),
          _buildGridMenu(context),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(icon: const Icon(Icons.assignment_outlined),
                onPressed: () => Navigator.pushNamed(context, '/orders')),
            const SizedBox(width: 40), // Espacio para el FAB
            IconButton(icon: const Icon(Icons.local_shipping_outlined),
                onPressed: () => Navigator.pushNamed(context, '/delivery/customers')),
            IconButton(icon: const Icon(Icons.bar_chart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/reports')),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¡Hola, Administrador!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
        const Text('Esto es lo que sucede hoy en tu cocina', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickStats() {
    final ordersService = context.read<OrdersService>();

    return Row(
      children: [
        Expanded(
          child: StreamBuilder<int>(
            stream: ordersService.watchPendingOrdersCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return _statCard(
                'Pendientes',
                count.toString(),
                Icons.receipt_long,
                count > 0 ? Colors.orange : Colors.blue,
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: StreamBuilder<double>(
            stream: ordersService.watchTodaySalesUsd(),
            builder: (context, snapshot) {
              final total = snapshot.data ?? 0.0;

              return _statCard(
                'Ventas Hoy',
                '\$${total.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _menuIcon(context, 'Productos', Icons.fastfood_outlined, Colors.orange, '/products'),
        _menuIcon(context, 'Ventas', Icons.monetization_on_outlined, Colors.green, '/sales'),
        _menuIcon(context, 'Inventario', Icons.inventory_2_outlined, Colors.blue, '/inventory'),
        _menuIcon(context, 'Gastos', Icons.money_off_outlined, Colors.red, '/expenses'),
        _menuIcon(context, 'Clientes', Icons.people_outline, Colors.purple, '/delivery/customers'),
        _menuIcon(context, 'Tasa', Icons.currency_exchange, Colors.teal, '/exchange-rate'),
      ],
    );
  }

  Widget _menuIcon(BuildContext context, String label, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}