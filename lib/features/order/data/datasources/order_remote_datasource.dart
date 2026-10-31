import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../../domain/entities/order_status.enum.dart';

abstract class OrderRemoteDataSource {
  Future<String?> createOrderWithStockReservation(OrderModel order);
  Future<void> submitPaymentReference(
    String orderId,
    String paymentReference,
    String clientPhone,
  );
  Future<List<OrderModel>> getOrdersForClient(String clientId);
  Future<List<OrderModel>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String?> createOrderWithStockReservation(OrderModel order) async {
    String newOrderId = '';

    await _firestore.runTransaction((transaction) async {
      final Map<DocumentReference, dynamic> updatesToExecute = {};
      final Map<String, double> requiredIngredientsDelta = {};

      // 1. Validar stock de cada producto y sus recetas
      for (var entry in order.items.entries) {
        final productId = entry.key;
        final requestedQuantity = entry.value;

        final productRef = _firestore.collection('products').doc(productId);
        final productSnap = await transaction.get(productRef);

        if (!productSnap.exists || productSnap.data() == null) {
          throw Exception('El producto con ID $productId ya no existe.');
        }

        final data = productSnap.data()!;
        final productName = data['name'] ?? 'Producto';
        final productType = data['type'] ?? 'comprado';
        final currentStock = data['stock'] ?? 0;

        if (currentStock < requestedQuantity) {
          throw Exception(
            'Stock insuficiente para "$productName". Disponible: $currentStock, solicitado: $requestedQuantity.',
          );
        }

        // Programar descuento del producto principal
        updatesToExecute[productRef] = {
          'stock': currentStock - requestedQuantity,
        };

        // Si es fabricado, acumular ingredientes de la receta
        if (productType == 'fabricado') {
          final List<dynamic> recipe = data['recipe'] ?? [];
          for (var rItem in recipe) {
            final ingredientId = rItem['ingredientId'];
            final double qtyPerUnit = (rItem['quantityRequired'] ?? 0.0)
                .toDouble();
            final double totalNeeded = qtyPerUnit * requestedQuantity;

            requiredIngredientsDelta[ingredientId] =
                (requiredIngredientsDelta[ingredientId] ?? 0.0) + totalNeeded;
          }
        }
      }

      // 2. Validar stock de ingredientes en el almacén
      for (var entry in requiredIngredientsDelta.entries) {
        final ingredientId = entry.key;
        final totalNeeded = entry.value;

        final ingredientRef = _firestore
            .collection('ingredients')
            .doc(ingredientId);
        final ingredientSnap = await transaction.get(ingredientRef);

        if (!ingredientSnap.exists || ingredientSnap.data() == null) {
          throw Exception(
            'Un ingrediente de la receta ya no existe en el almacén.',
          );
        }

        final ingData = ingredientSnap.data()!;
        final ingName = ingData['name'] ?? 'Insumo';
        final double currentIngStock = (ingData['stock'] ?? 0.0).toDouble();

        if (currentIngStock < totalNeeded) {
          throw Exception(
            'Almacén insuficiente de "$ingName". Disponible: $currentIngStock, necesario: $totalNeeded.',
          );
        }

        updatesToExecute[ingredientRef] = {
          'stock': currentIngStock - totalNeeded,
        };
      }

      // 3. Crear el documento del pedido
      final orderRef = _firestore.collection('orders').doc();
      newOrderId = orderRef.id;
      transaction.set(orderRef, order.toMap());

      // 4. Ejecutar todas las escrituras de inventario de forma atómica
      for (var entry in updatesToExecute.entries) {
        transaction.update(entry.key, entry.value);
      }
    });

    return newOrderId;
  }

  @override
  Future<void> submitPaymentReference(String orderId, String paymentReference, String clientPhone) async {
    await _firestore.collection('orders').doc(orderId).update({
      'paymentReference': paymentReference,
      'clientPhone': clientPhone,
      'status': OrderStatus.pendingVerification.name,
    });
  }

  @override
  Future<List<OrderModel>> getOrdersForClient(String clientId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // Si el estado cambia a REJECTED, debemos devolver el stock al inventario
    if (newStatus == OrderStatus.rejected) {
      await _firestore.runTransaction((transaction) async {
        final orderRef = _firestore.collection('orders').doc(orderId);
        final orderSnap = await transaction.get(orderRef);

        if (!orderSnap.exists) throw Exception('El pedido no existe.');

        final orderData = orderSnap.data()!;
        if (orderData['status'] == 'rejected') return; // Ya fue rechazado antes

        final Map<String, dynamic> items = orderData['items'] ?? {};

        // Devolver stock de productos e ingredientes
        for (var entry in items.entries) {
          final productId = entry.key;
          final qty = (entry.value as num).toInt();

          final productRef = _firestore.collection('products').doc(productId);
          final productSnap = await transaction.get(productRef);

          if (productSnap.exists) {
            final currentStock = productSnap.data()?['stock'] ?? 0;
            transaction.update(productRef, {'stock': currentStock + qty});

            if (productSnap.data()?['type'] == 'fabricado') {
              final List<dynamic> recipe = productSnap.data()?['recipe'] ?? [];
              for (var rItem in recipe) {
                final ingId = rItem['ingredientId'];
                final double qtyPerUnit = (rItem['quantityRequired'] ?? 0.0)
                    .toDouble();
                final double totalReturn = qtyPerUnit * qty;

                final ingRef = _firestore.collection('ingredients').doc(ingId);
                final ingSnap = await transaction.get(ingRef);
                if (ingSnap.exists) {
                  final currentIngStock = (ingSnap.data()?['stock'] ?? 0.0)
                      .toDouble();
                  transaction.update(ingRef, {
                    'stock': currentIngStock + totalReturn,
                  });
                }
              }
            }
          }
        }

        transaction.update(orderRef, {'status': newStatus.name});
      });
    } else {
      // Si solo es aprobado o entregado, actualizamos directamente
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.name,
      });
    }
  }
}
