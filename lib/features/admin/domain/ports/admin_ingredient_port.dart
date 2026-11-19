import 'package:maru_food_system/features/ingredient/domain/entities/ingredient_entity.dart';

abstract class AdminIngredientPort {
  Future<List<IngredientEntity>> getIngredients();
  Future<void> saveIngredient(IngredientEntity ingredient);
  Future<void> deleteIngredient(String ingredientId);
}