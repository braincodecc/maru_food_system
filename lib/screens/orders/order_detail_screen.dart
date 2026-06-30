import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order_model.dart';
import '../../models/order_status.dart';
import '../../services/orders_service.dart';
import '../../services/order_payment_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = false;

  // Función para llamar o escribir al cliente (UX Pro)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'No se pudo abrir $url';
  }

  @override
  Widget build(BuildContext context) {
    final orderPaymentService = context.read<OrderPaymentService>();
    final ordersService = context.read<OrdersService>();
    late final status = widget.order.statusEnum;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // Fondo suave para resaltar tarjetas
      appBar: AppBar(
        title: Text("Orden #${widget.order.id.substring(0, 5)}"),
        // ID corto para UX
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(status),
                const SizedBox(height: 16),
                _buildCustomerCard(),
                const SizedBox(height: 16),
                _buildOrderItems(),
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 100),
                // Espacio para los botones inferiores
              ],
            ),
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: SafeArea(
          child: _buildActions(
            context,
            status,
            ordersService,
            orderPaymentService,
          ),
        ),
      ),
    );
  }

  // Tarjeta de Estado (Resalta el progreso actual)
  Widget _buildStatusHeader(OrderStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: status.color),
          const SizedBox(width: 12),
          Text(
            "Estado: ${status.label}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de Cliente con acciones rápidas
  Widget _buildCustomerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "CLIENTE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing:
                  1.1, // Un poco de espacio entre letras mejora el look
            ),
          ),
        ),
        Card(
          color: Colors.blueGrey.shade50,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                    backgroundColor: Colors.black12,
                    foregroundColor: Colors.blueGrey,
                  ),
                  title: Text(
                    widget.order.customerName ?? 'Cliente Desconocido',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(widget.order.customerPhone ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () =>
                            _launchUrl('tel:${widget.order.customerPhone}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _launchUrl(
                          'https://wa.me/${widget.order.customerPhone}',
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.order.customerAddress != null) ...[
                  const Divider(),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.order.customerAddress!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Lista de Productos con diseño de "Ticket"
  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "PRODUCTOS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing:
              1.1, // Un poco de espacio entre letras mejora el look
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...widget.order.items
            .map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item.quantity}x",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      "\$${((item.quantity ?? 0) * (item.priceUsd ?? 0)).toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  // Resumen de Totales
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _summaryRow("Tasa de cambio", "Bs ${widget.order.exchangeRate}"),
          const Divider(height: 24),
          _summaryRow(
            "Total USD",
            "\$${widget.order.totalUsd.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 8),
          _summaryRow(
            "Total en Bolívares",
            "Bs ${widget.order.totalBs.toStringAsFixed(2)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            color: bold ? Colors.green : Colors.black,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            color: bold ? Colors.green : Colors.black,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction({
    required Future<dynamic> Function() action,
    required String successMessage,
  }) async {
    setState(() => _loading = true);
    try {
      final result = await action();

      if (result is String) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildActions(
    BuildContext context,
    OrderStatus status,
    OrdersService ordersService,
    OrderPaymentService orderPaymentService,
  ) {
    switch (status) {
      case OrderStatus.pending:
        return _pendingActions(context, ordersService, orderPaymentService);
      case OrderStatus.paid:
        return _paidActions(context, ordersService);
      case OrderStatus.completed:
        return _completedActions(context, ordersService);
      case OrderStatus.delivered:
        return _infoStatus("Orden Entregada", OrderStatus.delivered.color, Icons.check_circle_outline);
      case OrderStatus.cancelled:
        return _infoStatus("Orden Cancelada", OrderStatus.cancelled.color, Icons.highlight_off);
    }
  }

  Widget _pendingActions(
    BuildContext context,
    OrdersService orders,
    OrderPaymentService payment,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 50, // Altura estándar para mejor UX táctil
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrderStatus.paid.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _loading
                ? null
                : () => _handleAction(
                    action: () => payment.confirmPayment(widget.order.id),
                    successMessage: "Pago confirmado y venta registrada",
                  ),
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.payments_outlined),
            label: _loading
                ? const _LoadingIcon()
                : const Text(
                    "CONFIRMAR PAGO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 8), // Espaciado controlado
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade50, // 🔥 Color de fondo
              foregroundColor: OrderStatus.cancelled.color, // Color del texto e icono
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _loading
                ? null
                : () => _handleAction(
                    action: () => orders.changeStatus(
                      orderId: widget.order.id,
                      nextStatus: OrderStatus.cancelled,
                    ),
                    successMessage: "Pedido cancelado",
                  ),
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.cancel_outlined),
            label: _loading
                ? const _LoadingIcon()
                : const Text("Cancelar Pedido", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _paidActions(BuildContext context, OrdersService orders) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrderStatus.completed.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: _loading
                ? null
                : () => _handleAction(
                    action: () => orders.changeStatus(
                      orderId: widget.order.id,
                      nextStatus: OrderStatus.completed,
                    ),
                    successMessage: "Pedido preparado",
                  ),
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.inventory_2),
            label: _loading
                ? const _LoadingIcon()
                : const Text(
                    "MARCAR COMO PREPARADO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Al marcar como preparado, se notificará que está listo.",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _completedActions(BuildContext context, OrdersService orders) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Mantenemos la consistencia estructural
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          // Altura estándar para evitar que el cuerpo de la página salte
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrderStatus.delivered.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed: _loading
                ? null
                : () => _handleAction(
                    action: () => orders.changeStatus(
                      orderId: widget.order.id,
                      nextStatus: OrderStatus.delivered,
                    ),
                    successMessage: "Pedido entregado",
                  ),
            // UX: El icono de camión o paquete entregado
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.local_shipping_outlined),
            label: _loading
                ? const _LoadingIcon()
                : const Text(
                    "CONFIRMAR ENTREGA FINAL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Esta acción cerrará el ciclo del pedido.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _infoStatus(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper pequeño para no repetir el indicador de carga
class _LoadingIcon extends StatelessWidget {
  const _LoadingIcon();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
