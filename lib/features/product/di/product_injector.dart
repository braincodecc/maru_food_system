// Importaciones del modulo de orden
import '../data/datasources/product_remote_datasource.dart';
import '../data/repositories_impl/product_repository_impl.dart';
import '../data/adapters/product_ingredient_adapter_impl.dart';
import '../domain/usecases/get_active_products_usecase.dart';
import '../domain/usecases/save_product_usecase.dart';
import '../domain/usecases/delete_product_usecase.dart';
import '../presentation/providers/product_provider.dart';

// Importaciones del módulo de ingredientes
import 'package:maru_food_system/features/ingredient/data/datasources/ingredient_remote_datasource.dart';
import 'package:maru_food_system/features/ingredient/data/repositories_impl/ingredient_repository_impl.dart';

/// Función fábrica que arma todo el árbol de dependencias del módulo Product
ProductProvider createProductProvider() {
  // 1. Data Sources de Productos y de Ingredientes (Firebase Firestore)
  final productRemoteDataSource = ProductRemoteDataSourceImpl();
  final ingredientRemoteDataSource = IngredientRemoteDataSourceImpl();

  // 2. Repositorios
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: productRemoteDataSource,
  );
  final ingredientRepository = IngredientRepositoryImpl(
    remoteDataSource: ingredientRemoteDataSource,
  );

  // 3. Adaptador de Ingredientes para el módulo de Productos
  final productIngredientAdapter = ProductIngredientAdapterImpl(
    ingredientRepository: ingredientRepository,
  );

  // 4. Casos de Uso
  final getActiveProductsUseCase = GetActiveProductsUseCase(
    productRepository: productRepository,
  );

  final saveProductUseCase = SaveProductUseCase(
    productRepository: productRepository,
    productIngredientPort: productIngredientAdapter,
  );

  final deleteProductUseCase = DeleteProductUseCase(
    productRepository: productRepository,
  );

  // 5. Provider de Presentación
  return ProductProvider(
    getActiveProductsUseCase: getActiveProductsUseCase,
    saveProductUseCase: saveProductUseCase,
    deleteProductUseCase: deleteProductUseCase,
  );
}
