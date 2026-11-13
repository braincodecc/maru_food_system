import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.enum.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.clientId,
    required super.totalAmount,
    required super.status,
    required super.paymentReference,
    required super.clientPhone,
    required super.createdAt,
    required super.items,
  });

  /// Convierte un documento de Firestore a OrderModel
  factory OrderModel.fromMap(String id, Map<String, dynamic> json) {
    // 1. Procesamos los items de forma segura
    List<OrderItemModel> parsedItems = [];
    final rawItems = json['items'];

    if (rawItems is List) {
      // Formato NUEVO: Es una lista de mapas (con snapshots)
      parsedItems = rawItems
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } else if (rawItems is Map) {
      // Formato VIEJO: Era un Map<String, dynamic> (ej: {"prod_1": 2})
      // Lo transformamos temporalmente para que no rompa la app al leer órdenes pasadas
      rawItems.forEach((productId, quantity) {
        parsedItems.add(
          OrderItemModel(
            productId: productId.toString(),
            productName: 'Producto histórico', // Texto por defecto para órdenes viejas
            unitPrice: 0.0,
            unitCost: 0.0,
            quantity: (quantity as num).toDouble(),
          ),
        );
      });
    }

    return OrderModel(
      id: id,
      clientId: json['clientId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.fromString(json['status'] as String),
      paymentReference: json['paymentReference'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: parsedItems,
          /*(json['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],*/
    );
  }

  /// Convierte el modelo a un mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'totalAmount': totalAmount,
      'status': status
          .name, // Guardamos el nombre del enum como String ('pendingVerification', etc.)
      'paymentReference': paymentReference,
      'clientPhone': clientPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items
          .map((item) => OrderItemModel.fromEntity(item).toMap())
          .toList(),
    };
  }

  /// Convierte una Entidad pura de dominio en un Modelo
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      clientId: entity.clientId,
      items: entity.items,
      totalAmount: entity.totalAmount,
      status: entity.status,
      paymentReference: entity.paymentReference,
      clientPhone: entity.clientPhone,
      createdAt: entity.createdAt,
    );
  }

  /// Convierte este OrderModel en una Entidad pura de dominio (OrderEntity)
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      clientId: clientId,
      items: items,
      totalAmount: totalAmount,
      status: status,
      paymentReference: paymentReference,
      clientPhone: clientPhone,
      createdAt: createdAt,
    );
  }

  /// Convierte un String a OrderStatus enum
  /*static OrderStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return OrderStatus.approved;
      case 'rejected':
        return OrderStatus.rejected;
      case 'delivered':
        return OrderStatus.delivered;
      case 'pendingVerification':
      default:
        return OrderStatus.pendingVerification;
    }
  }*/
}
