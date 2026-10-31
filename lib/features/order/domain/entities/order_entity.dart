import 'order_status.enum.dart';

class OrderEntity {
  final String id;
  final String clientId;
  final Map<String, int> items; // Mapa de productId -> cantidad solicitada
  final double totalAmount;
  final OrderStatus status;
  final String paymentReference; // Referencia de Pago Móvil del banco
  final String clientPhone;      // Teléfono de contacto del cliente
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.clientId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentReference,
    required this.clientPhone,
    required this.createdAt,
  });

  OrderEntity copyWith({
    String? id,
    String? clientId,
    Map<String, int>? items,
    double? totalAmount,
    OrderStatus? status,
    String? paymentReference,
    String? clientPhone,
    DateTime? createdAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentReference: paymentReference ?? this.paymentReference,
      clientPhone: clientPhone ?? this.clientPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}