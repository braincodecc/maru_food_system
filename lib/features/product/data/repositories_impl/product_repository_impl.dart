import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductEntity>> getActiveProducts() async {
    final models = await _remoteDataSource.getActiveProducts();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getAllProductsForAdmin() async {
    final models = await _remoteDataSource.getAllProductsForAdmin();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    final model = await _remoteDataSource.getProductById(productId);
    return model?.toEntity();
  }

  @override
  Future<void> createProduct(ProductEntity product) async {
    // Convertimos la entidad de dominio a ProductModel para poder enviarla a Firestore
    final model = ProductModel.fromEntity(product);
    await _remoteDataSource.createProduct(model);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await _remoteDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _remoteDataSource.deleteProduct(productId);
  }
}
