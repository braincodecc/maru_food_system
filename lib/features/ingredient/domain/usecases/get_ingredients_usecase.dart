import '../entities/ingredient_entity.dart';
import '../repositories/ingredient_repository.dart';

class GetIngredientsUseCase {
  final IngredientRepository _ingredientRepository;
  GetIngredientsUseCase({required IngredientRepository ingredientRepository})
    : _ingredientRepository = ingredientRepository;

  Future<List<IngredientEntity>> call() async {
    return await _ingredientRepository.getAllIngredients();
  }
}
