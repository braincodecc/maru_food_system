import '../entities/ingredient_entity.dart';

abstract class IngredientRepository {
  Future<List<IngredientEntity>> getAllIngredients();
  Future<void> createIngredient(IngredientEntity ingredient);
  Future<void> updateIngredient(IngredientEntity ingredient);
  Future<void> deleteIngredient(String ingredientId);
}