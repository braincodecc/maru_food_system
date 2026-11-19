// Importaciones del modulo de orden (local)
import '../data/datasources/product_remote_datasource.dart';
import '../data/repositories_impl/product_repository_impl.dart';
import '../data/adapters/product_ingredient_adapter_impl.dart';
import '../domain/usecases/get_active_products_usecase.dart';
import '../domain/usecases/save_product_usecase.dart';
import '../domain/usecases/delete_product_usecase.dart';

// Importamos las fábricas públicas del módulo de ingredientes
import 'package:maru_food_system/features/ingredient/di/ingredient_injector.dart';

// 💡 Función auxiliar privada para mantener seco (DRY) el inyector de productos
ProductRepositoryImpl _createProductRepository() {
  final productRemoteDataSource = ProductRemoteDataSourceImpl();
  return ProductRepositoryImpl(remoteDataSource: productRemoteDataSource);
}

/// 1. Fábrica pública para obtener los productos activos (Usado por Client y Admin)
GetActiveProductsUseCase createGetActiveProductsUseCase() {
  return GetActiveProductsUseCase(
    productRepository: _createProductRepository(),
  );
}

/// 2. Fábrica pública para guardar/crear/editar productos (Usado por Admin)
SaveProductUseCase createSaveProductUseCase() {
  // Solicitamos el caso de uso del módulo de ingredientes
  final getIngredientUnitCostUseCase = createGetIngredientUnitCostUseCase();

  // Creamos el adaptador inyectando dicho caso de uso
  final productIngredientAdapter = ProductIngredientAdapterImpl(
    getIngredientUnitCostUseCase: getIngredientUnitCostUseCase,
  );

  return SaveProductUseCase(
    productRepository: _createProductRepository(),
    productIngredientPort: productIngredientAdapter,
  );
}

/// 3. Fábrica pública para eliminar productos (Usado por Admin)
DeleteProductUseCase createDeleteProductUseCase() {
  return DeleteProductUseCase(
    productRepository: _createProductRepository(),
  );
}