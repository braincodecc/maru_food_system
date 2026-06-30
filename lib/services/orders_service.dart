import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order_model.dart';
import '../models/order_status.dart';
import 'order_flow_service.dart';

class OrdersService {
  final CollectionReference<Map<String, dynamic>> _db =
  FirebaseFirestore.instance.collection('orders');

  /// Crear pedido
  Future<String> createOrder(OrderModel order) async {
    final doc = await _db.add(order.toMap());
    return doc.id;
  }

  /// Obtener pedidos en tiempo real
  Stream<List<OrderModel>> getOrders() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(
                    doc.id,
                    Map<String, dynamic>.from(doc.data() as Map),
                ),
      )
          .toList(),
    );
  }

  /// Obtener pedido por identificador
  Future<OrderModel> getOrderById(String orderId) async {
    final doc = await _db.doc(orderId).get();
    return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// Actualizar estado
  Future<void> updateStatus(String orderId, String status) async {
    await _db.doc(orderId).update({'status': status, 'updatedAt': FieldValue.serverTimestamp(),});
  }

  /// Actualizar estado a pagado
  Future<void> markAsPaid(String orderId) async {
    await changeStatus(
      orderId: orderId,
      nextStatus: OrderStatus.paid,
    );

    await _db.doc(orderId).update({
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Actualizar estado (CONTROLADO)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final data = {
      'status': status.value,
      '${status.value}At': FieldValue.serverTimestamp(),
    };

    await _db.doc(orderId).update(data);
  }

  /// Cambiar estado de forma segura (CONTROLADO)
  Future<void> changeStatus({required String orderId, required OrderStatus nextStatus}) async {
    final doc = await _db.doc(orderId).get();

    if (!doc.exists) {
      throw Exception('Pedido no encontrado');
    }

    final data = doc.data() as Map<String, dynamic>;

    final currentStatus = OrderStatusX.fromString(
      data['status'],
    );

    if (!canTransition(currentStatus, nextStatus)) {
      throw Exception(
        'Transición inválida: ${currentStatus.value} → ${nextStatus.value}',
      );
    }

    await _db.doc(orderId).update({
      'status': nextStatus.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Validación de transición de estados
  bool canTransition(OrderStatus current, OrderStatus next) {
    return orderFlow[current]?.contains(next) ?? false;
  }

  /// Validación de referencia existente
  Future<bool> isReferenceUnique(String reference) async {
    final query = await _db
        .where('paymentReference', isEqualTo: reference.toUpperCase())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  /// Obtener cantidad de ordenes pendientes
  Stream<int> watchPendingOrdersCount() {
    return _db
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Obtener total de ventas del dia
  Stream<double> watchTodaySalesUsd() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _db
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold(0.0, (sum, doc) {
        // Usamos double.tryParse o cast dependiendo de cómo guardes el dato
        final data = doc.data();
        final double total = (data?['totalUsd'] as num? ?? 0.0).toDouble();
        return sum + total;
      });
    });
  }
}
