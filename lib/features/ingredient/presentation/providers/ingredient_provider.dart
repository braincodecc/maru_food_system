import 'package:flutter/foundation.dart';
import '../../domain/entities/ingredient_entity.dart';
import '../../domain/usecases/get_ingredients_usecase.dart';
import '../../domain/usecases/save_ingredient_usecase.dart';
import '../../domain/usecases/delete_ingredient_usecase.dart';

class IngredientProvider extends ChangeNotifier {
  final GetIngredientsUseCase _getIngredientsUseCase;
  final SaveIngredientUseCase _saveIngredientUseCase;
  final DeleteIngredientUseCase _deleteIngredientUseCase;

  IngredientProvider({
    required GetIngredientsUseCase getIngredientsUseCase,
    required SaveIngredientUseCase saveIngredientUseCase,
    required DeleteIngredientUseCase deleteIngredientUseCase,
  })  : _getIngredientsUseCase = getIngredientsUseCase,
        _saveIngredientUseCase = saveIngredientUseCase,
        _deleteIngredientUseCase = deleteIngredientUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<IngredientEntity> _ingredients = [];
  List<IngredientEntity> get ingredients => _ingredients;

  /// Carga todos los ingredientes desde Firestore
  Future<void> loadIngredients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ingredients = await _getIngredientsUseCase();
    } catch (e) {
      _errorMessage = 'Error al cargar los ingredientes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda o actualiza un ingrediente
  Future<bool> saveIngredient(IngredientEntity ingredient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _saveIngredientUseCase(ingredient);
      await loadIngredients(); // Recargamos la lista
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar el ingrediente: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un ingrediente por su ID
  Future<bool> deleteIngredient(String ingredientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteIngredientUseCase(ingredientId);
      await loadIngredients();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el ingrediente: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}