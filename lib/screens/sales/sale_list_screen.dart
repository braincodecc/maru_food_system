import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/sales_service.dart';
import '../../models/sale_model.dart';

class SaleListScreen extends StatelessWidget {
  const SaleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesService = context.read<SalesService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
      ),
      body: StreamBuilder<List<SaleModel>>(
        stream: salesService.getSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las ventas'));
          }

          final sales = snapshot.data ?? [];
          if (sales.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay ventas registradas', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final sale = sales[index];
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => _showSaleDetail(context, sale),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icono de Transacción Exitosa
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.shade100),
                              ),
                              child: Icon(Icons.paid_outlined, color: Colors.green.shade700),
                            ),
                            const SizedBox(width: 12),

                            // Información del Cliente y Método de Pago
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sale.customerName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  // Badge para el método de pago (Efectivo, Transferencia, etc.)
                                  _buildPaymentMethodBadge(sale.paymentMethod),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateStr,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),

                            // Totales en Moneda Dual (Destacados)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${sale.totalUsd.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '${sale.totalBs.toStringAsFixed(2)} Bs',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blueGrey.shade400,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Pie de la tarjeta: Información de auditoría rápida
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  "Venta registrada",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            // Indicador de acción
                            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
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

  void _showSaleDetail(BuildContext context, SaleModel sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 15),
              Text('Detalle de Venta', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(),
              Text('Cliente: ${sale.customerName}', style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt)}'),
              const SizedBox(height: 15),
              const Text('PRODUCTOS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Flexible( // Permite que la lista sea escroleable si hay muchos items
                child: ListView(
                  shrinkWrap: true,
                  children: sale.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.name}'),
                        Text('\$${(item.priceUsd * item.quantity).toStringAsFixed(2)}'),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const Divider(),
              _buildAmountRow('Método de pago:', sale.paymentMethod),
              _buildAmountRow('Tasa de cambio:', '${sale.exchangeRate.toStringAsFixed(2)} Bs'),
              const SizedBox(height: 10),
              _buildAmountRow('TOTAL USD:', '\$${sale.totalUsd.toStringAsFixed(2)}', isBold: true),
              _buildAmountRow('TOTAL BS:', 'Bs ${sale.totalBs.toStringAsFixed(2)}', isBold: true, color: Colors.green),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountRow(String label, String value, {bool isBold = false, Color? color}) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: isBold ? 16 : 14,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: style)],
      ),
    );
  }

  Widget _buildPaymentMethodBadge(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }
}