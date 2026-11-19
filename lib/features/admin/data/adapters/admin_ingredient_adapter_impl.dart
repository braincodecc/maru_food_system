import '../../domain/ports/admin_ingredient_port.dart';
import 'package:maru_food_system/features/ingredient/domain/entities/ingredient_entity.dart';
import 'package:maru_food_system/features/ingredient/domain/usecases/get_ingredients_usecase.dart';
import 'package:maru_food_system/features/ingredient/domain/usecases/save_ingredient_usecase.dart';
import 'package:maru_food_system/features/ingredient/domain/usecases/delete_ingredient_usecase.dart';

class AdminIngredientAdapterImpl implements AdminIngredientPort {
  final GetIngredientsUseCase _getIngredientsUseCase;
  final SaveIngredientUseCase _saveIngredientUseCase;
  final DeleteIngredientUseCase _deleteIngredientUseCase;

  AdminIngredientAdapterImpl({
    required GetIngredientsUseCase getIngredientsUseCase,
    required SaveIngredientUseCase saveIngredientUseCase,
    required DeleteIngredientUseCase deleteIngredientUseCase,
  })  : _getIngredientsUseCase = getIngredientsUseCase,
        _saveIngredientUseCase = saveIngredientUseCase,
        _deleteIngredientUseCase = deleteIngredientUseCase;

  @override
  Future<List<IngredientEntity>> getIngredients() async {
    return await _getIngredientsUseCase();
  }

  @override
  Future<void> saveIngredient(IngredientEntity ingredient) async {
    await _saveIngredientUseCase(ingredient);
  }

  @override
  Future<void> deleteIngredient(String ingredientId) async {
    await _deleteIngredientUseCase(ingredientId);
  }
}