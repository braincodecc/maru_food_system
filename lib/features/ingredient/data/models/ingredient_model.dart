import '../../domain/entities/ingredient_entity.dart';

class IngredientModel extends IngredientEntity {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.stock,
    required super.minStock,
    required super.unitCost,
  });

  /// Crea una instancia desde un documento de Firestore
  factory IngredientModel.fromMap(String id, Map<String, dynamic> json) {
    return IngredientModel(
      id: id,
      name: json['name'] ?? '',
      unit: json['unit'] ?? 'unidades',
      stock: (json['stock'] ?? 0.0).toDouble(),
      minStock: (json['minStock'] ?? 0.0).toDouble(),
      unitCost: (json['unitCost'] ?? 0.0).toDouble(),
    );
  }

  /// Convierte el objeto a un mapa para guardar o actualizar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'stock': stock,
      'minStock': minStock,
      'unitCost': unitCost,
    };
  }

  /// Convierte una Entidad pura de dominio en un Modelo de datos
  factory IngredientModel.fromEntity(IngredientEntity entity) {
    return IngredientModel(
      id: entity.id,
      name: entity.name,
      unit: entity.unit,
      stock: entity.stock,
      minStock: entity.minStock,
      unitCost: entity.unitCost,
    );
  }
}