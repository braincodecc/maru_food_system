class IngredientEntity {
  final String id;              // ID único del ingrediente o materia prima
  final String productId;       // ID del producto final al que pertenece (si aplica como receta fija)
  final String name;            // Nombre del ingrediente (ej: "Pulp de pollo", "Pan de hamburguesa", "Papas")
  final double quantityRequired;// Cantidad necesaria para fabricar una unidad del producto final
  final String unitOfMeasure;   // Unidad de medida (ej: "gramos", "unidades", "ml", "kg")

  const IngredientEntity({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantityRequired,
    required this.unitOfMeasure,
  });
}