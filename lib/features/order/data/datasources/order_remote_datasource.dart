import 'package:cloud_firestore/cloud_firestore.dart.';
import '../models/order_model.dart';
import '../../domain/entities/order_status.enum.dart';
import '../../../../app/errors/firebase_safe_call.extension.dart';

abstract class OrderRemoteDataSource {
  Future<String?> createOrderWithStockReservation(OrderModel order);
  Future<void> submitOrderPaymentReference(
    String orderId,
    String paymentReference,
    String clientPhone,
  );
  Future<List<OrderModel>> getOrdersForClient(String clientId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<bool> hasActiveOrder(String userId);
  Stream<OrderModel?> watchActiveOrder(String userId);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String?> createOrderWithStockReservation(OrderModel order) async {
    return Future(() async {
      String newOrderId = '';

      // 1. Declaramos la variable de excepción en el ámbito exterior
      Object? capturedError;

      try {
        await _firestore.runTransaction((transaction) async {
          try {
            final Map<DocumentReference, dynamic> updatesToExecute = {};
            final Map<String, double> requiredIngredientsDelta = {};

            // 1. Validar stock de cada producto y sus recetas
            for (var entry in order.items) {
              final productId = entry.productId;
              final requestedQuantity = entry.quantity;

              final productRef = _firestore
                  .collection('products')
                  .doc(productId);
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
                      (requiredIngredientsDelta[ingredientId] ?? 0.0) +
                      totalNeeded;
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
              final double currentIngStock = (ingData['stock'] ?? 0.0)
                  .toDouble();

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
          } catch (innerError) {
            // 2. ¡Guardamos el detalle exacto en la variable exterior!
            capturedError = innerError;
            rethrow; // Re-lanzamos para que Firestore aborte la transacción correctamente
          }
        });
      } catch (_) {
        // 3. La transacción falló y ya tenemos el error a salvo en 'capturedError'.
        // Si lo tenemos, lo lanzamos limpio para que el .guard() exterior lo intercepte.
        if (capturedError != null) {
          throw capturedError!;
        }
        rethrow;
      }

      return newOrderId;
    }).guard(); // Usamos la extensión para manejar errores de Firebase de manera limpia
  }

  @override
  Future<void> submitOrderPaymentReference(
    String orderId,
    String paymentReference,
    String clientPhone,
  ) async {
    await _firestore.collection('orders').doc(orderId).update(
      {
        'paymentReference': paymentReference,
        'clientPhone': clientPhone,
        'status': OrderStatus.pendingVerification.name,
      },
    ); //.guard(); // Usamos la extensión para manejar errores de Firebase de manera limpia
  }

  @override
  Future<List<OrderModel>> getOrdersForClient(String clientId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .get();
    //.guard(); // Usamos la extensión para manejar errores de Firebase de manera limpia

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    return Future(() async {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
    }).guard();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    return Future(() async {
      final docSnap = await _firestore.collection('orders').doc(orderId).get();

      if (!docSnap.exists) return null;

      return OrderModel.fromMap(docSnap.id, docSnap.data()!);
    }).guard();
  }

  @override
  Future<bool> hasActiveOrder(String clientId) async {
    return Future(() async {
      final snapshot = await _firestore
          .collection('orders')
          .where('clientId', isEqualTo: clientId)
          .where(
            'status',
            whereIn: [
              OrderStatus.pendingVerification.name,
              OrderStatus.approved.name,
            ],
          )
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    }).guard();
  }

  @override
  Stream<OrderModel?> watchActiveOrder(String userId) {
    return _firestore
        .collection('orders')
        .where('clientId', isEqualTo: userId)
        .where(
          'status',
          whereIn: [
            OrderStatus.pendingVerification.name,
            OrderStatus.approved.name,
          ],
        )
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return OrderModel.fromMap(
            snapshot.docs.first.id,
            snapshot.docs.first.data(),
          );
        });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    return Future(() async {
      if (newStatus == OrderStatus.rejected) {
        // 1. Declaramos la variable de excepción en el ámbito exterior
        Object? capturedError;

        try {
          await _firestore.runTransaction((transaction) async {
            try {
              // ==========================================
              // FASE 1: TODAS LAS LECTURAS (READS) PRIMERO
              // ==========================================
              final orderRef = _firestore.collection('orders').doc(orderId);
              final orderSnap = await transaction.get(orderRef);
              //transaction.update(orderRef, {'status': newStatus.name});

              if (!orderSnap.exists) throw Exception('El pedido no existe.');

              final orderData = orderSnap.data()!;
              if (orderData['status'] == 'rejected') return;

              final Map<String, dynamic> items = orderData['items'] ?? {};
              final Map<String, DocumentSnapshot> productSnapshots = {};
              final Map<String, DocumentSnapshot> ingredientSnapshots = {};

              for (var productId in items.keys) {
                final productRef = _firestore
                    .collection('products')
                    .doc(productId);
                final productSnap = await transaction.get(productRef);
                productSnapshots[productId] = productSnap;

                if (productSnap.exists &&
                    productSnap.data()?['type'] == 'fabricado') {
                  final List<dynamic> recipe =
                      productSnap.data()?['recipe'] ?? [];
                  for (var rItem in recipe) {
                    final ingId = rItem['ingredientId'];
                    if (ingId != null &&
                        !ingredientSnapshots.containsKey(ingId)) {
                      final ingRef = _firestore
                          .collection('ingredients')
                          .doc(ingId);
                      final ingSnap = await transaction.get(ingRef);
                      ingredientSnapshots[ingId] = ingSnap;
                    }
                  }
                }
              }

              // ==========================================
              // FASE 2: TODAS LAS ESCRITURAS (WRITES) DESPUÉS
              // ==========================================
              for (var entry in items.entries) {
                final productId = entry.key;
                final qty = (entry.value as num).toInt();
                final productSnap = productSnapshots[productId];

                if (productSnap != null && productSnap.exists) {
                  final productRef = _firestore
                      .collection('products')
                      .doc(productId);
                  final productData =
                      productSnap.data() as Map<String, dynamic>;
                  final currentStock = productData['stock'] ?? 0;
                  transaction.update(productRef, {'stock': currentStock + qty});

                  if (productData['type'] == 'fabricado') {
                    final List<dynamic> recipe = productData['recipe'] ?? [];
                    for (var rItem in recipe) {
                      final ingId = rItem['ingredientId'];
                      final double qtyPerUnit =
                          (rItem['quantityRequired'] ?? 0.0).toDouble();
                      final double totalReturn = qtyPerUnit * qty;

                      final ingSnap = ingredientSnapshots[ingId];
                      if (ingSnap != null && ingSnap.exists) {
                        final ingRef = _firestore
                            .collection('ingredients')
                            .doc(ingId);
                        final ingData = ingSnap.data() as Map<String, dynamic>;
                        final currentIngStock = (ingData['stock'] ?? 0.0)
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
            } catch (innerError) {
              // 2. ¡Guardamos el detalle exacto en la variable exterior!
              capturedError = innerError;
              rethrow; // Re-lanzamos para que Firestore aborte la transacción correctamente
            }
          });
        } catch (_) {
          // 3. La transacción falló y ya tenemos el error a salvo en 'capturedError'.
          // Si lo tenemos, lo lanzamos limpio para que el .guard() exterior lo intercepte.
          if (capturedError != null) {
            throw capturedError!;
          }
          rethrow;
        }
      } else {
        // Si solo se aprueba o entrega, es un update simple
        await _firestore.collection('orders').doc(orderId).update({
          'status': newStatus.name,
        });
      }
    }).guard();
  }
}
