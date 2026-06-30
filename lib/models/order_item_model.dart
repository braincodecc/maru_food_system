import 'cart_item.dart';

class OrderItemModel {
  final String productId;
  final String name;
  final double priceUsd;
  final double costUsd;
  final double profitUsd;
  final int quantity;
  final double totalUsd;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.priceUsd,
    required this.costUsd,
    required this.profitUsd,
    required this.quantity,
    required this.totalUsd,
  });

  /// 🔼 Para Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'priceUsd': priceUsd,
      'costUsd': costUsd,
      'profitUsd': profitUsd,
      'quantity': quantity,
      'totalUsd': totalUsd,
    };
  }

  /// 🔽 Desde Firestore
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      priceUsd: (map['priceUsd'] is num)
          ? (map['priceUsd'] as num).toDouble()
          : 0.0,
      costUsd: (map['costUsd'] is num)
          ? (map['costUsd'] as num).toDouble()
          : 0.0,
      profitUsd: (map['profitUsd'] is num)
          ? (map['profitUsd'] as num).toDouble()
          : 0.0,
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : 0,
      totalUsd: (map['totalUsd'] is num)
          ? (map['totalUsd'] as num).toDouble()
          : 0.0,
    );
  }

  factory OrderItemModel.fromCartItem(CartItem cartItem) {
    return OrderItemModel(
      productId: cartItem.product.id,
      name: cartItem.product.name,
      priceUsd: cartItem.product.priceUsd,
      costUsd: cartItem.product.costUsd,
      profitUsd: cartItem.product.profitUsd,
      quantity: cartItem.quantity,
      totalUsd: cartItem.total,
    );
  }
}
