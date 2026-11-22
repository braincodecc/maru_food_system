import 'package:flutter/material.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:provider/provider.dart';

import '../providers/admin_order_provider.dart';
import 'package:maru_food_system/features/identity/presentation/providers/identity_provider.dart';

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
      context.read<AdminOrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<AdminOrderProvider>();
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos - Admin'),
        actions: [
          // Botón para recargar pedidos manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => orderProvider.loadOrders(),
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
          : orderProvider.orders.isEmpty
          ? const Center(
              child: Text(
                'No hay pedidos registrados en el sistema.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => orderProvider.loadOrders(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  return _buildOrderCard(context, order, orderProvider);
                },
              ),
            ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderEntity order,
    AdminOrderProvider provider,
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
      case OrderStatus.ready:
        statusColor = Colors.lightGreen;
        break;
      case OrderStatus.rejected:
        statusColor = Colors.red;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.purple;
        break;
      case OrderStatus.completed:
        statusColor = Colors.teal;
        break;
      case OrderStatus.inPreparation:
        statusColor = Colors.amber;
        break;
      case OrderStatus.outForDelivery:
        statusColor = Colors.indigo;
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  order.isDelivery ? Icons.delivery_dining : Icons.storefront,
                  size: 16,
                  color: order.isDelivery ? Colors.indigo : Colors.teal,
                ),
                const SizedBox(width: 8),
                Text(
                  order.isDelivery
                      ? 'Modalidad: Delivery'
                      : 'Modalidad: Retiro en Local (Pickup)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: order.isDelivery ? Colors.indigo : Colors.teal[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Resumen de Productos del Pedido
            const Text(
              'Ítems solicitados:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            ...order.items.map(
              (item) => Text(
                '• ${item.productName} (Cant: ${item.quantity})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),
            _buildOrderActions(context, order, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(
    BuildContext context,
    OrderEntity order,
    AdminOrderProvider provider,
  ) {
    final List<Widget> primaryActions = [];

    switch (order.status) {
      case OrderStatus.awaitingPayment:
      case OrderStatus.pendingVerification:
        primaryActions.addAll([
          OutlinedButton.icon(
            onPressed: () => _confirmAction(
              context,
              'Rechazar Pedido',
              '¿Estás seguro de rechazar este pedido? El stock y los ingredientes serán devueltos al almacén automáticamente.',
              () => _applyStatusChange(
                context,
                provider,
                order,
                OrderStatus.rejected,
                successMessage:
                    'Pedido rechazado con éxito. Stock devuelto al almacén.',
              ),
              Colors.red,
            ),
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: order.status == OrderStatus.pendingVerification
                ? () => _applyStatusChange(
                    context,
                    provider,
                    order,
                    OrderStatus.approved,
                    successMessage:
                        '¡Pago aprobado con éxito! Pedido listo para cocina.',
                  )
                : null,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Aprobar Pago'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ]);
        break;

      case OrderStatus.approved:
        primaryActions.addAll([
          ElevatedButton.icon(
            onPressed: () => _applyStatusChange(
              context,
              provider,
              order,
              OrderStatus.inPreparation,
              successMessage: 'Pedido marcado como En Preparación.',
              successColor: Colors.amber.shade800,
            ),
            icon: const Icon(Icons.soup_kitchen, color: Colors.white),
            label: const Text('En Preparación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _applyStatusChange(
              context,
              provider,
              order,
              OrderStatus.ready,
              successMessage: 'Pedido marcado como Listo para Despacho.',
              successColor: Colors.lightGreen.shade700,
            ),
            icon: const Icon(Icons.done_all),
            label: const Text('Marcar Listo'),
          ),
        ]);
        break;

      case OrderStatus.inPreparation:
        primaryActions.add(
          ElevatedButton.icon(
            onPressed: () => _applyStatusChange(
              context,
              provider,
              order,
              OrderStatus.ready,
              successMessage: 'Pedido marcado como Listo para Despacho.',
              successColor: Colors.lightGreen.shade700,
            ),
            icon: const Icon(Icons.done_all, color: Colors.white),
            label: const Text('Marcar Listo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        );
        break;

      case OrderStatus.ready:
        if (!order.isDelivery) {
          primaryActions.add(
            ElevatedButton.icon(
              onPressed: () => _confirmAction(
                context,
                'Completar Pedido Pickup',
                '¿Confirmas que el cliente retiró el pedido en el local? Esto registrará los ingresos en las cuentas financieras.',
                () => _applyStatusChange(
                  context,
                  provider,
                  order,
                  OrderStatus.completed,
                  successMessage:
                      'Pedido completado e ingresos distribuidos en finanzas.',
                  successColor: Colors.teal,
                ),
                Colors.teal,
              ),
              icon: const Icon(Icons.task_alt, color: Colors.white),
              label: const Text('Completar Pedido (Pickup)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          );
        } else {
          primaryActions.add(
            ElevatedButton.icon(
              onPressed: () => _applyStatusChange(
                context,
                provider,
                order,
                OrderStatus.outForDelivery,
                successMessage: 'Pedido marcado como En Camino (Delivery).',
                successColor: Colors.indigo,
              ),
              icon: const Icon(Icons.delivery_dining, color: Colors.white),
              label: const Text('Salir a Reparto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          );
        }
        break;

      case OrderStatus.outForDelivery:
        primaryActions.add(
          ElevatedButton.icon(
            onPressed: () => _applyStatusChange(
              context,
              provider,
              order,
              OrderStatus.delivered,
              successMessage: 'Pedido marcado como Entregado.',
              successColor: Colors.purple,
            ),
            icon: const Icon(Icons.home_filled, color: Colors.white),
            label: const Text('Marcar Entregado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        );
        break;

      case OrderStatus.delivered:
        primaryActions.add(
          ElevatedButton.icon(
            onPressed: () => _confirmAction(
              context,
              'Completar Pedido',
              '¿Confirmas que el pedido finalizó correctamente? Esto registrará los ingresos en las cuentas financieras.',
              () => _applyStatusChange(
                context,
                provider,
                order,
                OrderStatus.completed,
                successMessage:
                    'Pedido completado e ingresos distribuidos en finanzas.',
                successColor: Colors.teal,
              ),
              Colors.teal,
            ),
            icon: const Icon(Icons.task_alt, color: Colors.white),
            label: const Text('Completar Pedido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        );
        break;

      case OrderStatus.completed:
      case OrderStatus.rejected:
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (primaryActions.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: primaryActions,
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                _showEmergencyStatusDialog(context, order, provider),
            icon: const Icon(Icons.tune, size: 16, color: Colors.grey),
            label: const Text(
              'Cambiar estado (Emergencia)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmergencyStatusDialog(
    BuildContext context,
    OrderEntity order,
    AdminOrderProvider provider,
  ) {
    OrderStatus selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Cambio Manual - #${order.id.substring(0, 6).toUpperCase()}',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usa esta opción solo en contingencias operativas (fallas de cocina, repartidor o soporte):',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<OrderStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo estado',
                      border: OutlineInputBorder(),
                    ),
                    items: OrderStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedStatus = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: selectedStatus == order.status
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                          final requiresFinanceConfirm =
                              selectedStatus == OrderStatus.completed ||
                              selectedStatus == OrderStatus.rejected;

                          if (requiresFinanceConfirm) {
                            _confirmAction(
                              context,
                              'Confirmar: ${selectedStatus.label}',
                              'Cambiar a "${selectedStatus.label}" puede afectar inventario o distribuir ingresos financieros. ¿Deseas continuar?',
                              () => _applyStatusChange(
                                context,
                                provider,
                                order,
                                selectedStatus,
                                successMessage:
                                    'Estado actualizado a "${selectedStatus.label}".',
                              ),
                              Colors.deepOrange,
                            );
                          } else {
                            _applyStatusChange(
                              context,
                              provider,
                              order,
                              selectedStatus,
                              successMessage:
                                  'Estado actualizado a "${selectedStatus.label}".',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Diálogo de confirmación para evitar rechazos accidentales (reutilizable)
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

  Future<void> _applyStatusChange(
    BuildContext context,
    AdminOrderProvider provider,
    OrderEntity order,
    OrderStatus targetStatus, {
    required String successMessage,
    Color successColor = Colors.green,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final success = await provider.changeOrderStatus(order.id, targetStatus);

    if (!mounted || messenger == null) return;

    if (success) {
      await provider.loadOrders();
      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: successColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'No fue posible actualizar el estado.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
