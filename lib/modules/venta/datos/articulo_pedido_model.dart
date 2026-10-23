import 'package:maru_food_system/models/cart_item.dart'; // Mantén tu import actual de CartItem si lo requieres

/// [ArticuloPedidoModel] es la traducción híbrida de OrderItemModel.
/// Modela cada producto (Hamburguesa, Bebida, etc.) dentro del carrito y del Pedido final.
class ArticuloPedidoModel {
  final String productId;
  final String name;
  final double priceUsd;
  final double costUsd;
  final double profitUsd;
  final int quantity;
  final double totalUsd;

  ArticuloPedidoModel({
    required this.productId,
    required this.name,
    required this.priceUsd,
    required this.costUsd,
    required this.profitUsd,
    required this.quantity,
    required this.totalUsd,
  });

  // ==========================================
  // CONVERSIÓN PARA CLOUD FIRESTORE
  // ==========================================

  /// Convierte el artículo a un Mapa. Mantiene las llaves originales en inglés
  /// para no romper la estructura de la colección 'orders' en Firebase.
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

  /// Construye el artículo desde los datos almacenados en Cloud Firestore.
  factory ArticuloPedidoModel.fromMap(Map<String, dynamic> map) {
    return ArticuloPedidoModel(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Producto sin nombre',
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

  // Usamos el patron constructor para crear una copia modificada del artículo, útil para actualizar cantidades o precios sin alterar el original.
  ArticuloPedidoModel copyWith({
    String? productId,
    String? name,
    double? priceUsd,
    double? costUsd,
    double? profitUsd,
    int? quantity,
    double? totalUsd,
  }) {
    return ArticuloPedidoModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      priceUsd: priceUsd ?? this.priceUsd,
      costUsd: costUsd ?? this.costUsd,
      profitUsd: profitUsd ?? this.profitUsd,
      quantity: quantity ?? this.quantity,
      totalUsd: totalUsd ?? this.totalUsd,
    );
  }

  // ==========================================
  // MAPEOS ADICIONALES DEL NEGOCIO
  // ==========================================

  /// Mapea de forma rápida un item del carrito viejo al nuevo formato del módulo de ventas.
  /// Nota: Si tu clase original se llama 'CartItem', asegúrate de apuntar al import correcto.
  factory ArticuloPedidoModel.fromCartItem(dynamic cartItem) {
    return ArticuloPedidoModel(
      productId: cartItem.product.id,
      name: cartItem.product.name,
      priceUsd: (cartItem.product.priceUsd is num)
          ? (cartItem.product.priceUsd as num).toDouble()
          : 0.0,
      costUsd: (mapHasProperty(cartItem.product, 'costUsd'))
          ? (cartItem.product.costUsd as num).toDouble()
          : 0.0,
      profitUsd: (mapHasProperty(cartItem.product, 'profitUsd'))
          ? (cartItem.product.profitUsd as num).toDouble()
          : 0.0,
      quantity: cartItem.quantity,
      totalUsd: (cartItem.total is num)
          ? (cartItem.total as num).toDouble()
          : 0.0,
    );
  }
}

/// Función auxiliar de seguridad por si las propiedades costUsd o profitUsd no existen en tu producto viejo.
bool mapHasProperty(dynamic object, String propertyName) {
  try {
    return object.toMap()[propertyName] != null;
  } catch (_) {
    return false;
  }
}
