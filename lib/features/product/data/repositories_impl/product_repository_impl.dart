import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductEntity>> getActiveProducts() async {
    final models = await _remoteDataSource.getActiveProducts();
    // Como ProductModel extiende de ProductEntity, podemos retornarlos directamente
    return models;
  }

  @override
  Future<List<ProductEntity>> getAllProductsForAdmin() async {
    final models = await _remoteDataSource.getAllProductsForAdmin();
    return models;
  }

  @override
  Future<ProductEntity?> getProductById(String productId) async {
    return await _remoteDataSource.getProductById(productId);
  }

  @override
  Future<List<ProductEntity>> validateStockForCheckout(Map<String, int> cartItems) async {
    // Para validar stock antes del pago, consultamos el estado real en Firestore
    // o podemos evaluar los productos solicitados directamente.
    final List<ProductEntity> problematicProducts = [];

    for (var entry in cartItems.entries) {
      final productId = entry.key;
      final requestedQty = entry.value;

      final product = await _remoteDataSource.getProductById(productId);
      if (product == null || product.stock < requestedQty) {
        if (product != null) {
          problematicProducts.add(product);
        }
      }
    }

    return problematicProducts;
  }

  @override
  Future<void> processCheckout(Map<String, int> cartItems) async {
    // Delega directamente en la transacción atómica del datasource remoto
    await _remoteDataSource.processCheckoutTransaction(cartItems);
  }

  @override
  Future<void> createProduct(ProductEntity product) async {
    // Convertimos la entidad de dominio a ProductModel para poder enviarla a Firestore
    final productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      type: product.type,
      purchasePrice: product.purchasePrice,
      salePrice: product.salePrice,
      stock: product.stock,
      minStock: product.minStock,
      maxStock: product.maxStock,
      isActive: product.isActive,
    );

    await _remoteDataSource.createProduct(productModel);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      type: product.type,
      purchasePrice: product.purchasePrice,
      salePrice: product.salePrice,
      stock: product.stock,
      minStock: product.minStock,
      maxStock: product.maxStock,
      isActive: product.isActive,
    );

    await _remoteDataSource.updateProduct(productModel);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _remoteDataSource.deleteProduct(productId);
  }
}