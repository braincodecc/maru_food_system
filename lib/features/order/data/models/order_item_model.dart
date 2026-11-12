import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.unitPrice,
    required super.unitCost,
    required super.quantity,
  });

  /// Convierte un documento de Firestore a OrderItemModel
  factory OrderItemModel.fromMap(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      unitCost: (json['unitCost'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
    );
  }

  /// Convierte el modelo a un Map compatible con Firestore para guardarlo o actualizarlo
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'unitCost': unitCost,
      'quantity': quantity,
    };
  }

  /// Convierte una Entidad pura de dominio en un Modelo
  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      productName: entity.productName,
      unitPrice: entity.unitPrice,
      unitCost: entity.unitCost,
      quantity: entity.quantity,
    );
  }
}
