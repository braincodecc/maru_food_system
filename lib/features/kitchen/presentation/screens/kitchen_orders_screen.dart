// features/kitchen/presentation/screens/kitchen_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import '../providers/kitchen_provider.dart';
import '../../../identity/identity.dart';

class KitchenOrdersScreen extends StatefulWidget {
  const KitchenOrdersScreen({super.key});

  @override
  State<KitchenOrdersScreen> createState() => _KitchenOrdersScreenState();
}

class _KitchenOrdersScreenState extends State<KitchenOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenProvider>().loadKitchenOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kitchenProvider = context.watch<KitchenProvider>();
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comanda de Cocina - Maru Food'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        actions: [
          // Botón para recargar pedidos manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => kitchenProvider.loadKitchenOrders(),
          ),
          // Botón de cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: kitchenProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : kitchenProvider.orders.isEmpty
              ? const Center(
                  child: Text(
                    'No hay pedidos activos en cocina.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => kitchenProvider.loadKitchenOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: kitchenProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = kitchenProvider.orders[index];
                      return _buildKitchenOrderCard(context, order, kitchenProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildKitchenOrderCard(
      BuildContext context, OrderEntity order, KitchenProvider provider) {
    final isApproved = order.status == OrderStatus.approved;
    final isInPrep = order.status == OrderStatus.inPreparation;
    final isReady = order.status == OrderStatus.ready;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de la orden
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: isApproved
                      ? Colors.orange
                      : isInPrep
                          ? Colors.blue
                          : Colors.green,
                ),
              ],
            ),
            const Divider(height: 20),

            // Listado de ítems (Snapshots)
            const Text(
              'Productos a preparar:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '• ${item.productName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'x${item.quantity.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            const Divider(),

            // Botones de acción según el estado actual
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isApproved)
                  ElevatedButton.icon(
                    onPressed: () => provider.startPreparation(order.id),
                    icon: const Icon(Icons.local_fire_department),
                    label: const Text('Iniciar Preparación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (isInPrep)
                  ElevatedButton.icon(
                    onPressed: () => provider.markAsReady(order.id),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marcar como Listo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (isReady)
                  const Text(
                    'Pedido listo en mostrador / esperando delivery',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
}
  }