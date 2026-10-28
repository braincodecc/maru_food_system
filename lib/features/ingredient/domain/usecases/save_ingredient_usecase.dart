import '../entities/ingredient_entity.dart';
import '../repositories/ingredient_repository.dart';

class SaveIngredientUseCase {
  final IngredientRepository _repository;
  SaveIngredientUseCase(this._repository);

  Future<void> call(IngredientEntity ingredient) async {
    if (ingredient.id.isEmpty) {
      await _repository.createIngredient(ingredient);
    } else {
      await _repository.updateIngredient(ingredient);
    }
  }
}