import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_report_model.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DailyReportModel> watchDailyReport(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) {

      final docs = snapshot.docs;

      return DailyReportModel(
        date: date,
        totalOrders: docs.length,
        deliveredOrders: _countDeliveredOrders(docs),
        totalSalesUsd: _calculateTotalSales(docs, 'totalUsd'),
        totalSalesBs: _calculateTotalSales(docs, 'totalBs'),
        totalProfitUsd: _calculateTotalProfit(docs),
        paymentMethods: _calculatePaymentMethods(docs),
        topProducts: _calculateTopProducts(docs),
      );
    });
  }

  // --- MÉTODOS DE PROCESAMIENTO ESPECIALIZADOS ---

  int _countDeliveredOrders(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) => doc.data()['status'] == 'delivered').length;
  }

  double _calculateTotalSales(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String field) {
    return docs.where((doc) => doc.data()['status'] == 'delivered') // Solo entregados
        .fold(0.0, (sum, doc) => sum + (doc.data()[field] as num? ?? 0).toDouble());
  }

  double _calculateTotalProfit(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) => doc.data()['status'] == 'delivered') // Solo entregados
        .fold(0.0, (sum, doc) => sum + (doc.data()['profitUsd'] as num? ?? 0).toDouble());
  }

  Map<String, double> _calculatePaymentMethods(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    Map<String, double> methods = {'efectivo': 0, 'pago móvil': 0, 'zelle': 0};

    for (var doc in docs) {
      final data = doc.data();
      if (data['status'] != 'delivered') continue; // Solo sumamos dinero de lo entregado

      final method = (data['paymentMethod'] as String? ?? 'efectivo').toLowerCase();
      final amount = (data['totalUsd'] as num? ?? 0).toDouble();

      if (methods.containsKey(method)) {
        methods[method] = (methods[method] ?? 0) + amount;
      }
    }
    return methods;
  }

  Map<String, int> _calculateTopProducts(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    Map<String, int> counts = {};
    for (var doc in docs) {
      if (doc.data()['status'] != 'delivered') continue;

      final List items = doc.data()['items'] ?? [];
      for (var item in items) {
        final name = item['name'] ?? 'Desconocido';
        final qty = (item['quantity'] as num? ?? 0).toInt();
        counts[name] = (counts[name] ?? 0) + qty;
      }
    }
    return counts;
  }
}