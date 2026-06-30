class RecipeItem {
  final String inventoryId;
  final String name;
  final double quantity;
  final double costPerUnit;

  RecipeItem({
    required this.inventoryId,
    required this.name,
    required this.quantity,
    required this.costPerUnit,
  });

  double get totalCost => quantity * costPerUnit;

  Map<String, dynamic> toMap() => {
    'inventoryId': inventoryId,
    'name': name,
    'quantity': quantity,
    'costPerUnit': costPerUnit,
  };

  factory RecipeItem.fromMap(Map<String, dynamic> map) {
    return RecipeItem(
      inventoryId: map['inventoryId'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      costPerUnit: (map['costPerUnit'] ?? 0).toDouble(),
    );
  }
}
