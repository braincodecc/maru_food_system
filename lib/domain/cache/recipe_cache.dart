import '../../models/recipe_model.dart';

class RecipeCache {
  final Map<String, RecipeModel> _map = {};

  void set(RecipeModel recipe) {
    _map[recipe.productId] = recipe;
  }

  RecipeModel? get(String productId) => _map[productId];

  bool has(String productId) => _map.containsKey(productId);
}
