import '../../domain/ports/product_ingredient_port.dart';
import 'package:maru_food_system/features/ingredient/domain/usecases/get_ingredient_unit_cost_usecase.dart';

class ProductIngredientAdapterImpl implements ProductIngredientPort {
  final GetIngredientUnitCostUseCase _getIngredientUnitCostUseCase;

  ProductIngredientAdapterImpl({
    required GetIngredientUnitCostUseCase getIngredientUnitCostUseCase,
  }) : _getIngredientUnitCostUseCase = getIngredientUnitCostUseCase;

  @override
  Future<double?> getIngredientUnitCost(String ingredientId) async {
    // El adaptador simplemente delega la llamada al caso de uso oficial del módulo de ingredientes
    return await _getIngredientUnitCostUseCase(ingredientId);
  }
}