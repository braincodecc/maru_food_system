class RecipeItemEntity {
  final String ingredientId;   // ID del ingrediente en la colección de ingredientes
  final double quantityRequired; // Cantidad que gasta este plato (ej: 150 gramos de carne)
  

  const RecipeItemEntity({
    required this.ingredientId,
    required this.quantityRequired,
  });
}