import '../entities/ingredient_entity.dart';
import '../repositories/ingredient_repository.dart';

class SaveIngredientUseCase {
  final IngredientRepository _ingredientRepository;
  
  SaveIngredientUseCase({required IngredientRepository ingredientRepository})
    : _ingredientRepository = ingredientRepository;

  Future<void> call(IngredientEntity ingredient) async {
    if (ingredient.id.isEmpty) {
      await _ingredientRepository.createIngredient(ingredient);
    } else {
      await _ingredientRepository.updateIngredient(ingredient);
    }
  }
}