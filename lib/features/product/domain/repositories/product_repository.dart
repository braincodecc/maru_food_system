import '../entities/product_entity.dart';

abstract class ProductRepository {
  /// Obtiene la lista de productos activos para mostrar en el menú del cliente
  Future<List<ProductEntity>> getActiveProducts();

  /// Obtiene todos los productos (activos e inactivos) para la gestión del administrador
  Future<List<ProductEntity>> getAllProductsForAdmin();

  /// Obtiene un producto específico por su ID
  Future<ProductEntity?> getProductById(String productId);

  // --- Métodos de Gestión del Administrador ---

  /// Crea un nuevo producto (comprado o fabricado con su lista de materiales)
  Future<void> createProduct(ProductEntity product);

  /// Actualiza un producto existente
  Future<void> updateProduct(ProductEntity product);

  /// Desactiva o elimina un producto lógicamente del inventario
  Future<void> deleteProduct(String productId);
}