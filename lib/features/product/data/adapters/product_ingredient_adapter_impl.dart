import '../../domain/services/product_ingredient_service.dart';
import 'package:maru_food_system/features/ingredient/domain/repositories/ingredient_repository.dart';

class ProductIngredientAdapterImpl implements ProductIngredientService {
  final IngredientRepository _ingredientRepository; // El repositorio real del otro módulo

  ProductIngredientAdapterImpl(this._ingredientRepository);

  @override
  Future<double?> getIngredientUnitCost(String ingredientId) async {
    // Consultamos el repositorio de ingredientes y adaptamos el resultado a lo que el producto necesita
    final ingredient = await _ingredientRepository.getIngredientById(ingredientId);
    return ingredient?.unitCost;
  }
}