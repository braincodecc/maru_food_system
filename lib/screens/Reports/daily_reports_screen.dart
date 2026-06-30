import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import '../../models/daily_report_model.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class DailyReportsScreen extends StatefulWidget {
  const DailyReportsScreen({super.key});

  @override
  State<DailyReportsScreen> createState() => _DailyReportsScreenState();
}

class _DailyReportsScreenState extends State<DailyReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reportsService = context.read<ReportsService>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cierre de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          )
        ],
      ),
      body: StreamBuilder<DailyReportModel>(
        stream: reportsService.watchDailyReport(_selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.totalOrders == 0) {
            return _buildEmptyState();
          }

          final report = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDateHeader(),
              const SizedBox(height: 16),
              _buildMainFinancialCard(report),
              const SizedBox(height: 20),
              _buildSectionTitle('Desglose por Métodos de Pago'),
              _buildPaymentMethodsGrid(report.paymentMethods),
              const SizedBox(height: 24),
              _buildSectionTitle('Productos más Vendidos'),
              _buildTopProductsList(report.topProducts),
              const SizedBox(height: 80), // Espacio extra al final
            ],
          );
        },
      ),
    );
  }

  // --- COMPONENTES DE LA UI ---

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate).toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMainFinancialCard(DailyReportModel report) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('VENTAS ENTREGADAS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$${report.totalSalesUsd.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
            Text('${report.totalSalesBs.toStringAsFixed(2)} Bs', style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoColumn('Órdenes', '${report.deliveredOrders}/${report.totalOrders}', Icons.shopping_bag_outlined),
                _infoColumn('Ganancia', '\$${report.totalProfitUsd.toStringAsFixed(2)}', Icons.trending_up, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsGrid(Map<String, double> methods) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.3,
      crossAxisSpacing: 10,
      children: [
        _paymentMethodCard('Efectivo', methods['efectivo'] ?? 0, Colors.green),
        _paymentMethodCard('Pago Móvil', methods['pago móvil'] ?? 0, Colors.blue),
        _paymentMethodCard('Zelle', methods['zelle'] ?? 0, Colors.purple),
      ],
    );
  }

  Widget _paymentMethodCard(String label, double amount, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('\$${amount.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopProductsList(Map<String, int> products) {
    // Ordenar productos por cantidad de mayor a menor
    final sortedList = products.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mantenemos el estándar de título que aplicamos antes
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedList.length,
          itemBuilder: (context, index) {
            final entry = sortedList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  // Indicador de Posición (Ranking) con el diseño estándar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "#${index + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre del Producto
                  Expanded(
                    child: Text(
                      entry.key, // Nombre del producto
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text('${entry.value} uds', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
/*
  Widget _buildTopProductsList(Map<String, int> products) {
    // Ordenar productos por cantidad de mayor a menor
    final sortedList = products.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sortedList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
            ),
            title: Text(entry.key, style: const TextStyle(fontSize: 14)),
            trailing: Text('${entry.value} uds', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
*/
  // --- HELPERS ---

  Widget _infoColumn(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No hay actividad registrada', style: TextStyle(color: Colors.grey, fontSize: 16)),
          TextButton(onPressed: () => setState(() => _selectedDate = DateTime.now()), child: const Text('Volver a hoy')),
        ],
      ),
    );
  }
}