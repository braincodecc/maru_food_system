import '../data/datasources/ingredient_remote_datasource.dart';
import '../data/repositories_impl/ingredient_repository_impl.dart';
import '../domain/usecases/get_ingredients_usecase.dart';
import '../domain/usecases/save_ingredient_usecase.dart';
import '../domain/usecases/delete_ingredient_usecase.dart';
import '../domain/usecases/get_ingredient_unit_cost_usecase.dart';

IngredientRepositoryImpl _createIngredientRepository() {
  final remoteDataSource = IngredientRemoteDataSourceImpl();
  return IngredientRepositoryImpl(remoteDataSource: remoteDataSource);
}

GetIngredientsUseCase createGetIngredientsUseCase() {
  return GetIngredientsUseCase(
    ingredientRepository: _createIngredientRepository(),
  );
}

SaveIngredientUseCase createSaveIngredientUseCase() {
  return SaveIngredientUseCase(
    ingredientRepository: _createIngredientRepository(),
  );
}

DeleteIngredientUseCase createDeleteIngredientUseCase() {
  return DeleteIngredientUseCase(
    ingredientRepository: _createIngredientRepository(),
  );
}

GetIngredientUnitCostUseCase createGetIngredientUnitCostUseCase() {
  return GetIngredientUnitCostUseCase(
    ingredientRepository: _createIngredientRepository(),
  );
}