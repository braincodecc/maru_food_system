class RecipeItemModel {
  final String inventoryItemId;
  final String name;
  final double quantity;
  final String unit;
  final double costPerUnit;

  RecipeItemModel({
    required this.inventoryItemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
  });

  double get totalCost => quantity * costPerUnit;

  Map<String, dynamic> toMap() {
    return {
      'inventoryItemId': inventoryItemId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'costPerUnit': costPerUnit,
    };
  }

  factory RecipeItemModel.fromMap(Map<String, dynamic> map) {
    return RecipeItemModel(
      inventoryItemId: map['inventoryItemId'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] is num)
          ? (map['quantity'] as num).toDouble()
          : 0.0,
      unit: map['unit'] ?? '',
      costPerUnit: (map['costPerUnit'] is num)
          ? (map['costPerUnit'] as num).toDouble()
          : 0.0,
    );
  }
}
