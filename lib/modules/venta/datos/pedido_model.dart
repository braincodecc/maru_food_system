import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maru_food_system/models/location_model.dart';
import 'package:maru_food_system/models/order_status.dart';
import 'articulo_pedido_model.dart';

/// [PedidoModel] optimizado para el Módulo de Venta Express de Maru Food System.
/// Se eliminaron campos redundantes para acelerar la facturación en horas pico.
class PedidoModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final LocationModel? customerLocation; // Contiene lat, lng y dirección de texto interna
  final String orderType;                // delivery | pickup
  final String paymentMethod;            // Efectivo, Pago Móvil, Zelle, etc.
  final String? paymentReference;
  final double exchangeRate;
  final double totalUsd;
  final double totalBs;
  final double profitUsd;
  final List<ArticuloPedidoModel> items;
  final String status;                   // pending | completed | cancelled
  final DateTime createdAt;
  final bool isPendingAdminEnrichment;   // Bandera para revisión nocturna

  PedidoModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerLocation,
    this.orderType = 'pickup',          // Por defecto retiro en local para agilizar
    required this.paymentMethod,
    this.paymentReference,
    required this.exchangeRate,
    required this.totalUsd,
    required this.totalBs,
    required this.profitUsd,
    required this.items,
    required this.status,
    required this.createdAt,
    this.isPendingAdminEnrichment = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerLocation': customerLocation?.toMap(), // Si es null, Firebase lo guarda vacío de forma segura
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'exchangeRate': exchangeRate,
      'totalUsd': totalUsd,
      'totalBs': totalBs,
      'profitUsd': profitUsd,
      'items': items.map((e) => e.toMap()).toList(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPendingAdminEnrichment': isPendingAdminEnrichment,
    };
  }

  factory PedidoModel.fromMap(String id, Map<String, dynamic> map) {
    return PedidoModel(
      id: id,
      customerName: map['customerName'] ?? 'Cliente Express',
      customerPhone: map['customerPhone'] ?? '',
      customerLocation: map['customerLocation'] != null
          ? LocationModel.fromMap(Map<String, dynamic>.from(map['customerLocation']))
          : null,
      orderType: map['orderType'] ?? 'pickup',
      paymentMethod: map['paymentMethod'] ?? 'Efectivo',
      paymentReference: map['paymentReference'],
      exchangeRate: (map['exchangeRate'] ?? 0).toDouble(),
      totalUsd: (map['totalUsd'] ?? 0).toDouble(),
      totalBs: (map['totalBs'] ?? 0).toDouble(),
      profitUsd: (map['profitUsd'] ?? 0).toDouble(),
      items: (map['items'] is List)
          ? (map['items'] as List).map((e) => ArticuloPedidoModel.fromMap(e)).toList()
          : [],
      status: map['status'] ?? 'completed',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPendingAdminEnrichment: map['isPendingAdminEnrichment'] ?? false,
    );
  }

  /// Expone el enum OrderStatus original de tu app
  OrderStatus get statusEnum => OrderStatusX.fromString(status);
}
