import '../../domain/ports/product_ingredient_port.dart';
import 'package:maru_food_system/features/ingredient/domain/repositories/ingredient_repository.dart';

class ProductIngredientAdapterImpl implements ProductIngredientPort {
  final IngredientRepository
  _ingredientRepository;

  ProductIngredientAdapterImpl({
    required IngredientRepository ingredientRepository,
  }) : _ingredientRepository = ingredientRepository;

  @override
  Future<double?> getIngredientUnitCost(String ingredientId) async {
    final ingredient = await _ingredientRepository.getIngredientById(
      ingredientId,
    );
    return ingredient?.unitCost;
  }
}
