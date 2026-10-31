import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.enum.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.clientId,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.paymentReference,
    required super.clientPhone,
    required super.createdAt,
  });

  /// Convierte un documento de Firestore a OrderModel
  factory OrderModel.fromMap(String id, Map<String, dynamic> json) {
    // Mapeamos los ítems de Map<String, dynamic> a Map<String, int>
    final rawItems = json['items'] as Map<String, dynamic>? ?? {};
    final Map<String, int> parsedItems = rawItems.map((key, value) => MapEntry(key, (value as num).toInt()));

    return OrderModel(
      id: id,
      clientId: json['clientId'] ?? '',
      items: parsedItems,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: _parseStatus(json['status']),
      paymentReference: json['paymentReference'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convierte el modelo a un mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status.name, // Guardamos el nombre del enum como String ('pendingVerification', etc.)
      'paymentReference': paymentReference,
      'clientPhone': clientPhone,
      'createdAt': Timestamp.fromDate(createdAt),
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

  static OrderStatus _parseStatus(String? statusStr) {
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
  }
}