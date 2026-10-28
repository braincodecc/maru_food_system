import '../entities/ingredient_entity.dart';
import '../repositories/ingredient_repository.dart';

class GetIngredientsUseCase {
  final IngredientRepository _repository;
  GetIngredientsUseCase(this._repository);

  Future<List<IngredientEntity>> call() async {
    return await _repository.getAllIngredients();
  }
}