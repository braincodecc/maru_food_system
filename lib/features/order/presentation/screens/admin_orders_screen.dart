import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../order.dart';
import '../../../identity/identity.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos los pedidos apenas entra el administrador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos - Admin'),
        actions: [
          // Botón para recargar pedidos manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => orderProvider.loadAllOrders(),
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
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  orderProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : orderProvider.allOrders.isEmpty
          ? const Center(
              child: Text(
                'No hay pedidos registrados en el sistema.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => orderProvider.loadAllOrders(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderProvider.allOrders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.allOrders[index];
                  return _buildOrderCard(context, order, orderProvider);
                },
              ),
            ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderEntity order,
    OrderProvider provider,
  ) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.awaitingPayment:
        statusColor = Colors.orange;
        break;
      case OrderStatus.pendingVerification:
        statusColor = Colors.blue;
        break;
      case OrderStatus.approved:
        statusColor = Colors.green;
        break;
      case OrderStatus.rejected:
        statusColor = Colors.red;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.purple;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: ID del pedido y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido: #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const Divider(),

            // Información de Pago y Contacto
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Teléfono: ${order.clientPhone.isNotEmpty ? order.clientPhone : 'No indicado'}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.receipt, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Ref. Pago Móvil: ${order.paymentReference.isNotEmpty ? order.paymentReference : 'Pendiente por enviar'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: order.paymentReference.isEmpty
                        ? Colors.orange
                        : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Resumen de Productos del Pedido
            const Text(
              'Ítems solicitados:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            ...order.items.entries.map(
              (entry) => Text(
                '• Producto ID: ${entry.key} (Cant: ${entry.value})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            // Botones de Acción para el Administrador
            if (order.status == OrderStatus.awaitingPayment ||
                order.status == OrderStatus.pendingVerification)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _confirmAction(
                      context,
                      'Rechazar Pedido',
                      '¿Estás seguro de rechazar este pedido? El stock y los ingredientes serán devueltos al almacén automáticamente.',
                      () async {
                        final messenger = ScaffoldMessenger.maybeOf(context);

                        // 1. Ejecutamos el cambio de estado y capturamos el booleano resultante
                        final success = await provider.changeOrderStatus(
                          order.id,
                          OrderStatus.rejected,
                        );

                        // Verificamos que el widget siga montado antes de usar el contexto
                        if (!mounted || messenger == null) return;

                        if (success) {
                          // 2. Refrescamos la lista de órdenes y el stock de productos
                          await provider.loadAllOrders();

                          // 3. Mostramos mensaje de éxito
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pedido rechazado con éxito. Stock devuelto al almacén.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else {
                          // 4. Si falló, mostramos el mensaje de error que trae el provider
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errorMessage ??
                                    'No fue posible rechazar la orden.',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      Colors.red,
                    ),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Rechazar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(
                    onPressed: order.status == OrderStatus.pendingVerification ? () async {
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      final success = await provider.changeOrderStatus(
                        order.id,
                        OrderStatus.approved,
                      );

                      if (!mounted || messenger == null) return;

                      if (success) {
                        await provider.loadAllOrders();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              '¡Pago aprobado con éxito! Pedido pasado a preparación.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ??
                                  'Error al aprobar el pedido.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } : null,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Aprobar Pago'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            else if (order.status == OrderStatus.approved)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => provider.changeOrderStatus(
                    order.id,
                    OrderStatus.delivered,
                  ),
                  icon: const Icon(Icons.local_shipping, color: Colors.white),
                  label: const Text('Marcar como Entregado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Diálogo de confirmación para evitar rechazos accidentales
  void _confirmAction(
    BuildContext
    parentContext, // 1. Renombramos para dejar claro que es el contexto de la pantalla
    String title,
    String content,
    Future<void> Function() onConfirm,
    Color color,
  ) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        // 2. Usamos un 'dialogContext' exclusivo para cerrar la ventana
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
              ), // 3. Cerramos el diálogo usando su propio contexto
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                ); // 4. Cerramos el diálogo antes de ejecutar la acción
                await onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
