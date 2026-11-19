import '../repositories/ingredient_repository.dart';

class GetIngredientUnitCostUseCase {
  final IngredientRepository _ingredientRepository;

  GetIngredientUnitCostUseCase({required IngredientRepository ingredientRepository})
      : _ingredientRepository = ingredientRepository;

  Future<double?> call(String ingredientId) async {
    final ingredient = await _ingredientRepository.getIngredientById(ingredientId);
    return ingredient?.unitCost;
  }
}