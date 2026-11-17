import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/delivery_provider.dart';

// Importaciones del modulo de ordenes
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

class DeliveryOrdersScreen extends StatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  State<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends State<DeliveryOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().loadDeliveryOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logística & Delivery - Maru Food 🛵'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => deliveryProvider.loadDeliveryOrders(),
          ),
        ],
      ),
      body: deliveryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveryProvider.deliveries.isEmpty
              ? const Center(
                  child: Text(
                    'No hay entregas pendientes en ruta.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => deliveryProvider.loadDeliveryOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: deliveryProvider.deliveries.length,
                    itemBuilder: (context, index) {
                      final order = deliveryProvider.deliveries[index];
                      return _buildDeliveryCard(context, order, deliveryProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildDeliveryCard(
      BuildContext context, OrderEntity order, DeliveryProvider provider) {
    final isReady = order.status == OrderStatus.ready;
    final isOut = order.status == OrderStatus.outForDelivery;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido Delivery #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: isReady ? Colors.amber[800] : Colors.blue,
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Teléfono del Cliente: ${order.clientPhone}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Total a Cobrar / Verificado: \$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isReady)
                  ElevatedButton.icon(
                    onPressed: () => provider.markAsOrderOutForDelivery(order.id),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Salir a Repartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (isOut)
                  ElevatedButton.icon(
                    onPressed: () => provider.markAsOrderCompleted(order.id),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar Entrega'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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