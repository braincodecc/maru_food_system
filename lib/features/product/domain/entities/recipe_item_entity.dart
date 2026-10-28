class RecipeItemEntity {
  final String ingredientId;   // ID del ingrediente en la colección de ingredientes
  final String ingredientName; // Nombre para mostrar en el resumen sin hacer JOIN pesado
  final double quantityRequired; // Cantidad que gasta este plato (ej: 150 gramos de carne)

  const RecipeItemEntity({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantityRequired,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantityRequired': quantityRequired,
    };
  }

  factory RecipeItemEntity.fromMap(Map<String, dynamic> map) {
    return RecipeItemEntity(
      ingredientId: map['ingredientId'] ?? '',
      ingredientName: map['ingredientName'] ?? '',
      quantityRequired: (map['quantityRequired'] ?? 0.0).toDouble(),
    );
  }
}