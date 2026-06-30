import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItemModel {
  final String id;
  final String name;
  final String unit;
  final double stock;
  final double costPerUnit;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.costPerUnit,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItemModel.fromMap(String id, Map<String, dynamic> map) {
    return InventoryItemModel(
      id: id,
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      stock: (map['stock'] is num) ? (map['stock'] as num).toDouble() : 0.0,
      costPerUnit: (map['costPerUnit'] is num)
          ? (map['costPerUnit'] as num).toDouble()
          : 0.0,
      active: map['active'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'stock': stock,
      'costPerUnit': costPerUnit,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is InventoryItemModel &&
              runtimeType == other.runtimeType &&
              id == other.id; // Comparamos por ID, no por posición en memoria

  @override
  int get hashCode => id.hashCode;

}
