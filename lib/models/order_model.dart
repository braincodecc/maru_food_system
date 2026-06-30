import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maru_food_system/models/order_item_model.dart';
import 'location_model.dart';
import 'order_status.dart';

class OrderModel {
  final String id;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final LocationModel? deliveryLocation;
  final String orderType; // delivery | pickup
  final String paymentMethod;
  final String? paymentReference;
  final String currency;
  final double exchangeRate;
  final double totalUsd;
  final double totalBs;
  final double profitUsd;
  final List<OrderItemModel> items;
  final String status; // pending  | completed | delivered | paid |cancelled
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? completedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderModel({
    required this.id,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    this.deliveryLocation,
    this.orderType = 'delivery',
    required this.paymentMethod,
    this.paymentReference,
    required this.currency,
    required this.exchangeRate,
    required this.totalUsd,
    required this.totalBs,
    required this.profitUsd,
    required this.items,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.completedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'deliveryLocation': deliveryLocation?.toMap(),
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'totalUsd': totalUsd,
      'totalBs': totalBs,
      'profitUsd': profitUsd,
      'items': items.map((e) => e.toMap()).toList(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      deliveryLocation: map['deliveryLocation'] != null
          ? LocationModel.fromMap(
              Map<String, dynamic>.from(map['deliveryLocation']),
            )
          : null,
      orderType: map['orderType'] ?? 'delivery',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentReference: map['paymentReference'] ?? '',
      currency: map['currency'] ?? '',
      exchangeRate: (map['exchangeRate'] ?? 0).toDouble(),
      totalUsd: (map['totalUsd'] ?? 0).toDouble(),
      totalBs: (map['totalBs'] ?? 0).toDouble(),
      profitUsd: (map['profitUsd'] ?? 0).toDouble(),
      items: (map['items'] is List)
          ? (map['items'] as List)
                .map((e) => OrderItemModel.fromMap(e))
                .toList()
          : [],
      status: map['status'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      paidAt: (map['paidAt'] is Timestamp)
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
      completedAt: (map['completedAt'] is Timestamp)
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: (map['deliveredAt'] is Timestamp)
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,
      cancelledAt: (map['cancelledAt'] is Timestamp)
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// exponer el enum OrderStatus
  OrderStatus get statusEnum => OrderStatusX.fromString(status);
}
