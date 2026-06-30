import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double priceUsd;
  final double costUsd;     // 🔥 NUEVO
  final double profitUsd;  // 🔥 NUEVO
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.priceUsd,
    required this.costUsd,
    required this.profitUsd,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'priceUsd': priceUsd,
      'costUsd': costUsd,
      'profitUsd': profitUsd,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      priceUsd: (map['priceUsd'] ?? 0).toDouble(),
      costUsd: (map['costUsd'] ?? 0).toDouble(),
      profitUsd: (map['profitUsd'] ?? 0).toDouble(),
      active: map['active'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
