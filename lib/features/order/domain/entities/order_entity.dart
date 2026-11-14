import 'order_status.enum.dart';
import 'order_item_entity.dart';

class OrderEntity {
  final String id;
  final String clientId;
  final double totalAmount;
  final OrderStatus status;
  final String paymentReference; // Referencia de Pago Móvil del banco
  final String clientPhone;      // Teléfono de contacto del cliente
  final bool isDelivery;         // true = Delivery, false = Pickup (Retiro)
  final DateTime createdAt;
  final List<OrderItemEntity> items; // Mapa de productId -> cantidad solicitada

  const OrderEntity({
    required this.id,
    required this.clientId,
    required this.totalAmount,
    required this.status,
    required this.paymentReference,
    required this.clientPhone,
    this.isDelivery = false, // Por defecto retiro en local si no se especifica
    required this.createdAt,
    required this.items,
  });

  OrderEntity copyWith({
    String? id,
    String? clientId,
    double? totalAmount,
    OrderStatus? status,
    String? paymentReference,
    String? clientPhone,
    bool? isDelivery,
    DateTime? createdAt,
    List<OrderItemEntity>? items,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentReference: paymentReference ?? this.paymentReference,
      clientPhone: clientPhone ?? this.clientPhone,
      isDelivery: isDelivery ?? this.isDelivery,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}