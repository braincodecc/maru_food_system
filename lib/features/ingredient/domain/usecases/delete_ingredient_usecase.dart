import '../repositories/ingredient_repository.dart';

class DeleteIngredientUseCase {
  final IngredientRepository _ingredientRepository;
  
  DeleteIngredientUseCase({required IngredientRepository ingredientRepository})
    : _ingredientRepository = ingredientRepository;

  Future<void> call(String ingredientId) async {
    return await _ingredientRepository.deleteIngredient(ingredientId);
  }
}