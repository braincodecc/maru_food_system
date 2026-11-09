class RecipeItemEntity {
  final String ingredientId;   // ID del ingrediente en la colección de ingredientes
  final double quantityRequired; // Cantidad que gasta este plato (ej: 150 gramos de carne)
  

  const RecipeItemEntity({
    required this.ingredientId,
    required this.quantityRequired,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'quantityRequired': quantityRequired,
    };
  }

  factory RecipeItemEntity.fromMap(Map<String, dynamic> map) {
    return RecipeItemEntity(
      ingredientId: map['ingredientId'] ?? '',
      quantityRequired: (map['quantityRequired'] ?? 0.0).toDouble(),
    );
  }
}