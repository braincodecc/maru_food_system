import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';
import '../models/inventory_item_model.dart';
import '../models/recipe_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';

class OrderPaymentService {
  final _db = FirebaseFirestore.instance;

  /// MÉTODO PARA CONFIRMAR PAGO DE ORDEN
  /// DESCUENTO DE INVENTARIOS
  /// CREACIÓN DE VENTA
  Future<String?> confirmPayment(String orderId) async {
    String? mensajeRescatado;

    try {
      await _db.runTransaction((transaction) async {
        // 1. Obtener y validar la orden básica
        final orderRef = _db.collection('orders').doc(orderId);
        final orderSnap = await transaction.get(orderRef);

        if (!orderSnap.exists) {
          mensajeRescatado = 'El documento orden no existe en Firestore';
          throw Exception(mensajeRescatado);
        }

        final data = orderSnap.data();

        if (data == null) {
          mensajeRescatado = 'El documento orden está vacío en Firestore';
          throw Exception(mensajeRescatado);
        }

        final order = OrderModel.fromMap(orderSnap.id, data);

        if (order.status != 'pending') {
          mensajeRescatado =
              'El documento orden no tiene el estado pendiente en Firestore';
          throw Exception(mensajeRescatado);
        }

        // 2. FASE DE LECTURA: Validar stock y recolectar operaciones
        // Guardamos las referencias para actualizar al final
        final List<Map<String, dynamic>> stockUpdates = [];

        mensajeRescatado = await _validarStockYRecetas(
          transaction,
          order,
          stockUpdates,
        );

        if (mensajeRescatado != null) throw mensajeRescatado!;

        // 3. FASE DE ESCRITURA: Ejecutar cambios
        _ejecutarEscrituras(transaction, orderRef, order, stockUpdates);
      });
      return null;
    } on FirebaseException catch (e) {
      return _handleFirebaseError(e); // Captura errores específicos de Firestore (Permisos, Red, etc.)
    } catch (e) {
      //Revisar el problema con el tiempo, el proceso de creación demora a pesar que crea todo correctamente.
      return (mensajeRescatado != null) ? mensajeRescatado : e.toString();
    }
  }

  /// MÉTODO PARA VALIDAR STOCK (FASE DE LECTURA)
  Future<String?> _validarStockYRecetas(
    Transaction transaction,
    OrderModel order,
    List<Map<String, dynamic>> stockUpdates,
  ) async {
    for (final orderItem in order.items) {
      final recipeRef = _db.collection('recipes').doc(orderItem.productId);
      final recipeSnap = await transaction.get(recipeRef);

      if (!recipeSnap.exists) {
        return 'El producto ${orderItem.name} no tiene receta configurada';
      }

      final data = recipeSnap.data();

      if (data == null) {
        return 'La receta del producto ${orderItem.name} está vacía';
      }

      final recipe = RecipeModel.fromMap(recipeSnap.id, data);

      for (final recipeItem in recipe.items) {
        final invRef = _db
            .collection('inventory')
            .doc(recipeItem.inventoryItemId);
        final invSnap = await transaction.get(invRef);

        if (!invSnap.exists) return 'Insumo ${recipeItem.name} no encontrado';

        final data = invSnap.data();

        if (data == null) {
          return 'La receta del producto ${orderItem.name} está vacía';
        }

        final inventory = InventoryItemModel.fromMap(
          invSnap.id,
          data,
        );
        final requiredQty = recipeItem.quantity * orderItem.quantity;

        if ((inventory.stock ?? 0) < requiredQty) {
          return 'Stock insuficiente para ${recipeItem.name}';
        }

        // Agregamos a la lista de pendientes para la fase de escritura
        stockUpdates.add({'ref': invRef, 'qty': -requiredQty});
      }
    }

    return null; // Todo ok
  }

  /// MÉTODO PARA ESCRITURAS (FASE DE EJECUCIÓN)
  void _ejecutarEscrituras(
    Transaction transaction,
    DocumentReference orderRef,
    OrderModel order,
    List<Map<String, dynamic>> stockUpdates,
  ) {
    // A. Descontar Inventario
    for (var update in stockUpdates) {
      transaction.update(update['ref'], {
        'stock': FieldValue.increment(update['qty']),
      });
    }

    // B. Crear Venta
    final saleRef = _db.collection('sales').doc();
    final saleModel = _prepareSaleModel(order.id, order);
    transaction.set(saleRef, saleModel.toMap());

    // C. Finalizar Orden
    transaction.update(orderRef, {
      'status': 'paid',
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Helper para el modelo de venta (como el anterior)
  SaleModel _prepareSaleModel(String orderId, OrderModel order) {
    final saleItems = order.items.map((orderItem) {
      return SaleItemModel(
        productId: orderItem.productId,
        name: orderItem.name,
        priceUsd: orderItem.priceUsd,
        costUsd: orderItem.costUsd,
        profitUsd: orderItem.profitUsd,
        quantity: orderItem.quantity,
        totalUsd: orderItem.totalUsd,
      );
    }).toList();

    return SaleModel(
      id: '',
      orderId: orderId,
      customerId: order.customerId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      deliveryLocation: order.deliveryLocation,
      orderType: order.orderType,
      paymentMethod: order.paymentMethod,
      paymentReference: order.paymentReference,
      currency: order.currency,
      exchangeRate: order.exchangeRate,
      totalUsd: order.totalUsd,
      totalBs: order.totalBs,
      profitUsd: order.profitUsd,
      items: saleItems,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  /// Función auxiliar para traducir códigos de Firebase a mensajes humanos
  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'No tienes permisos para realizar esta operación.';
      case 'unavailable':
        return 'El servicio no está disponible temporalmente.';
      case 'deadline-exceeded':
        return 'La operación tardó demasiado. Intenta de nuevo.';
      default:
        return 'Error de base de datos: ${e.message}';
    }
  }
}
