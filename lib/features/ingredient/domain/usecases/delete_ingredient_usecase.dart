import '../repositories/ingredient_repository.dart';

class DeleteIngredientUseCase {
  final IngredientRepository _repository;
  DeleteIngredientUseCase(this._repository);

  Future<void> call(String ingredientId) async {
    return await _repository.deleteIngredient(ingredientId);
  }
}