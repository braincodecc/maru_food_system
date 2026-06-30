import 'package:flutter/material.dart';
import 'package:maru_food_system/models/order_status.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/orders_service.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.read porque el stream mantiene la conexión
    final ordersService = context.read<OrdersService>();

    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos")),
      body: StreamBuilder<List<OrderModel>>(
        stream: ordersService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Aún no tienes pedidos",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(12),
            // Padding consistente con productos e inventario
            itemBuilder: (_, index) {
              final order = orders[index];
              final dateStr = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(order.createdAt);
              final status =
                  order.statusEnum; // Usamos el enum que ya configuramos

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/order-detail',
                    arguments: order,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icono visual según el estado o tipo de orden
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: status.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                color: status.color,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Información del Cliente e ID
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.customerName ?? "Cliente General",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ID: #${order.id.substring(0, 6)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Badge de Estado dinámico
                                  _buildStatusBadge(status),
                                ],
                              ),
                            ),

                            // Totales destacados
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${order.totalUsd.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Información inferior: Cantidad de items y tipo de orden
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${order.items.length} productos",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            // Botón visual que indica que se puede entrar al detalle
                            Row(
                              children: [
                                Text(
                                  "VER DETALLE",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.blue.shade700,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        // Un diseño más "pill" (píldora)
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
