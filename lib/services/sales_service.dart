import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/sale_model.dart';

class SalesService {
  final CollectionReference _ref = FirebaseFirestore
      .instance
      .collection('sales');

  /// Registrar una venta en Firestore
  Future<void> registerSale(SaleModel sale) async {
    await _ref.add(sale.toMap());
  }

  /// Registrar una venta desde una orden en Firestore
  Future<void> createSaleFromOrder(OrderModel order, double profitUsd) async {
    await _ref.add({
      'orderId': order.id,
      'customerName': order.customerName,
      'customerPhone': order.customerPhone,
      'items': order.items,
      'totalUsd': order.totalUsd,
      'totalBs': order.totalBs,
      'profitUsd': profitUsd,
      'exchangeRate': order.exchangeRate,
      'paymentMethod': order.paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtener ventas en tiempo real
  Stream<List<SaleModel>> getSales() {
    return _ref
        .orderBy('createdAt', descending: true) // CAMPO CORRECTO
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SaleModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }
}
