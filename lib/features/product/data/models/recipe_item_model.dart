import '../../domain/entities/recipe_item_entity.dart';

class RecipeItemModel extends RecipeItemEntity {
  const RecipeItemModel({
    required super.ingredientId,
    required super.quantityRequired,
  });

  Map<String, dynamic> toMap() {
    return {'ingredientId': ingredientId, 'quantityRequired': quantityRequired};
  }

  factory RecipeItemModel.fromMap(Map<String, dynamic> map) {
    return RecipeItemModel(
      ingredientId: map['ingredientId'] ?? '',
      quantityRequired: (map['quantityRequired'] as num?)?.toDouble() ?? 0.0,
    );
  }
  /// Convierte una Entidad pura de dominio en un Modelo
  factory RecipeItemModel.fromEntity(RecipeItemEntity entity) {
    return RecipeItemModel(
      ingredientId: entity.ingredientId,
      quantityRequired: entity.quantityRequired,
    );
  }
}
