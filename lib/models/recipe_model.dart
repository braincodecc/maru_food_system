import 'package:cloud_firestore/cloud_firestore.dart';

import 'recipe_item_model.dart';

class RecipeModel {
  final String id;
  final String productId;
  final String productName;
  final List<RecipeItemModel> items;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.items,
    required this.createdAt,
  });

  /// 💰 Costo total de la receta
  double get totalCost => items.fold(0, (sum, item) => sum + item.totalCost);

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'items': items.map((e) => e.toMap()).toList(),
      'totalCost': totalCost,
      'createdAt': createdAt,
    };
  }

  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      items: (map['items'] is List)
          ? (map['items'] as List)
                .map((e) => RecipeItemModel.fromMap(e))
                .toList()
          : [],
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
