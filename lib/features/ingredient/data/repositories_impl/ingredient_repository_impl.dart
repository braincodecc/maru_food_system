import '../../domain/entities/ingredient_entity.dart';
import '../../domain/repositories/ingredient_repository.dart';
import '../datasources/ingredient_remote_datasource.dart';
import '../models/ingredient_model.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientRemoteDataSource _remoteDataSource;

  IngredientRepositoryImpl({
    required IngredientRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<IngredientEntity>> getAllIngredients() async {
    return await _remoteDataSource.getAllIngredients();
  }

  @override
  Future<void> createIngredient(IngredientEntity ingredient) async {
    final model = IngredientModel.fromEntity(ingredient);
    await _remoteDataSource.createIngredient(model);
  }

  @override
  Future<void> updateIngredient(IngredientEntity ingredient) async {
    final model = IngredientModel.fromEntity(ingredient);
    await _remoteDataSource.updateIngredient(model);
  }

  @override
  Future<void> deleteIngredient(String ingredientId) async {
    await _remoteDataSource.deleteIngredient(ingredientId);
  }
}