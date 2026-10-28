class IngredientEntity {
  final String id; // ID único del ingrediente o materia prima
  final String name; // Nombre del ingrediente (ej: "Pulp de pollo", "Pan de hamburguesa", "Papas")
  final String unit; // Ej: 'gramos', 'unidades', 'ml', 'kg'
  final double stock; // Stock actual en el almacén
  final double minStock; // Stock mínimo para alertas de reposición
  final double unitCost; // Costo de compra de la unidad base

  const IngredientEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.minStock,
    required this.unitCost,
  });

  /// Regla de negocio: Determina si el ingrediente necesita reposición urgente
  bool get needsRestock => stock <= minStock;

  IngredientEntity copyWith({
    String? id,
    String? name,
    String? unit,
    double? stock,
    double? minStock,
    double? unitCost,
  }) {
    return IngredientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}
