import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_model.dart';
import 'sale_item_model.dart';

class SaleModel {
  final String id;
  final String orderId;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final LocationModel? deliveryLocation;
  final String orderType; // delivery | pickup
  final String paymentMethod;
  final String? paymentReference;
  final String currency; // 'USD' o 'BS'
  final double exchangeRate;
  final double totalUsd;
  final double totalBs;
  final double profitUsd;
  final List<SaleItemModel> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SaleModel({
    required this.id,
    required this.orderId,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    this.deliveryLocation,
    required this.orderType,
    required this.paymentMethod,
    this.paymentReference,
    required this.currency,
    required this.exchangeRate,
    required this.totalUsd,
    required this.totalBs,
    required this.profitUsd,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  // 🔼 Enviar a Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'deliveryLocation': deliveryLocation?.toMap(),
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference ?? '',
      'currency': currency ?? 'USD',
      'exchangeRate': (exchangeRate ?? 0.0).toDouble(),
      'totalUsd': (totalUsd ?? 0.0).toDouble(),
      'totalBs': (totalBs ?? 0.0).toDouble(),
      'profitUsd': (profitUsd ?? 0.0).toDouble(),
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // 🔽 Leer desde Firestore
  factory SaleModel.fromMap(String id, Map<String, dynamic> map) {
    return SaleModel(
      id: id,
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      deliveryLocation: map['deliveryLocation'] != null
          ? LocationModel.fromMap(
        Map<String, dynamic>.from(map['deliveryLocation']),
      )
          : null,
      orderType: map['orderType'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentReference: map['paymentReference'] ?? '',
      currency: map['currency'] ?? 'USD',
      exchangeRate: (map['exchangeRate'] ?? 1).toDouble(),
      totalUsd: (map['totalUsd'] is int)
          ? (map['totalUsd'] as int).toDouble()
          : (map['totalUsd'] ?? 0.0).toDouble(),
      totalBs: (map['totalBs'] is int)
          ? (map['totalBs'] as int).toDouble()
          : (map['totalBs'] ?? 0.0).toDouble(),
      profitUsd: (map['profitUsd'] is int)
          ? (map['profitUsd'] as int).toDouble()
          : (map['profitUsd'] ?? 0.0).toDouble(),
      items: (map['items'] is List)
          ? (map['items'] as List)
          .map((e) => SaleItemModel.fromMap(e))
          .toList()
          : [],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}