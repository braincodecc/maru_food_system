import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/ingredient/domain/entities/ingredient_entity.dart';
import '../../domain/ports/admin_ingredient_port.dart';

class AdminIngredientProvider extends ChangeNotifier {
  final AdminIngredientPort _adminIngredientPort;

  AdminIngredientProvider({required AdminIngredientPort adminIngredientPort})
      : _adminIngredientPort = adminIngredientPort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<IngredientEntity> _ingredients = [];
  List<IngredientEntity> get ingredients => _ingredients;

  Future<void> loadIngredients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ingredients = await _adminIngredientPort.getIngredients();
    } catch (e) {
      _errorMessage = 'Error al cargar los ingredientes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveIngredient(IngredientEntity ingredient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminIngredientPort.saveIngredient(ingredient);
      await loadIngredients();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar el ingrediente: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteIngredient(String ingredientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminIngredientPort.deleteIngredient(ingredientId);
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