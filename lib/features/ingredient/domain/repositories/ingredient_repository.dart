import '../entities/ingredient_entity.dart';

abstract class IngredientRepository {
  Future<List<IngredientEntity>> getAllIngredients();
  /// Obtiene un ingrediente específico por su ID
  Future<IngredientEntity?> getIngredientById(String ingredientId);
  Future<void> createIngredient(IngredientEntity ingredient);
  Future<void> updateIngredient(IngredientEntity ingredient);
  Future<void> deleteIngredient(String ingredientId);
}