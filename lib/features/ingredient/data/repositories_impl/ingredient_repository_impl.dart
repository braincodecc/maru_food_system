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
    final model = await _remoteDataSource.getAllIngredients();
    return model.map((ingredientModel) => ingredientModel.toEntity()).toList();
  }

  @override
  Future<IngredientEntity?> getIngredientById(String ingredientId) async {
    final model = await _remoteDataSource.getIngredientById(ingredientId);
    return model?.toEntity();
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
