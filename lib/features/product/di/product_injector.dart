import '../data/datasources/product_remote_datasource.dart';
import '../data/repositories_impl/product_repository_impl.dart';
import '../domain/usecases/get_active_products_usecase.dart';
import '../domain/usecases/process_checkout_usecase.dart';
import '../domain/usecases/validate_cart_stock_usecase.dart';
import '../domain/usecases/save_product_usecase.dart';
import '../domain/usecases/delete_product_usecase.dart';
import '../presentation/providers/product_provider.dart';

/// Función fábrica que arma todo el árbol de dependencias del módulo Product
ProductProvider createProductProvider() {
  // 1. Data Source (Firebase Firestore)
  final remoteDataSource = ProductRemoteDataSourceImpl();

  // 2. Repositorio
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);

  // 3. Casos de Uso
  final getActiveProductsUseCase = GetActiveProductsUseCase(repository);
  final validateCartStockUseCase = ValidateCartStockUseCase(repository);
  final processCheckoutUseCase = ProcessCheckoutUseCase(repository);
  final saveProductUseCase = SaveProductUseCase(repository);
  final deleteProductUseCase = DeleteProductUseCase(repository);

  // 4. Provider de Presentación
  return ProductProvider(
    getActiveProductsUseCase: getActiveProductsUseCase,
    validateCartStockUseCase: validateCartStockUseCase,
    processCheckoutUseCase: processCheckoutUseCase,
    saveProductUseCase: saveProductUseCase,
    deleteProductUseCase: deleteProductUseCase,
  );
}
