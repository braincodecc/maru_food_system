import '../data/datasources/ingredient_remote_datasource.dart';
import '../data/repositories_impl/ingredient_repository_impl.dart';
import '../domain/usecases/get_ingredients_usecase.dart';
import '../domain/usecases/save_ingredient_usecase.dart';
import '../domain/usecases/delete_ingredient_usecase.dart';
import '../presentation/providers/ingredient_provider.dart';

IngredientProvider createIngredientProvider() {
  final remoteDataSource = IngredientRemoteDataSourceImpl();
  final repository = IngredientRepositoryImpl(remoteDataSource: remoteDataSource);

  final getIngredientsUseCase = GetIngredientsUseCase(repository);
  final saveIngredientUseCase = SaveIngredientUseCase(repository);
  final deleteIngredientUseCase = DeleteIngredientUseCase(repository);

  return IngredientProvider(
    getIngredientsUseCase: getIngredientsUseCase,
    saveIngredientUseCase: saveIngredientUseCase,
    deleteIngredientUseCase: deleteIngredientUseCase,
  );
}