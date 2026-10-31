import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  /// Obtiene todos los productos con isActive == true desde Firestore
  Future<List<ProductModel>> getActiveProducts();

  /// Obtiene todos los productos (activos e inactivos) para la vista del administrador
  Future<List<ProductModel>> getAllProductsForAdmin();

  /// Obtiene un producto individual por su ID
  Future<ProductModel?> getProductById(String productId);

  /// Crea un nuevo producto en la colección de Firestore
  Future<void> createProduct(ProductModel product);

  /// Actualiza un producto existente en Firestore
  Future<void> updateProduct(ProductModel product);

  /// Realiza un borrado lógico (isActive = false) o físico en Firestore
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _collection => 'products';

  @override
  Future<List<ProductModel>> getActiveProducts() async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<ProductModel>> getAllProductsForAdmin() async {
    final querySnapshot = await _firestore.collection(_collection).get();

    return querySnapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection(_collection).doc(productId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id.isNotEmpty ? product.id : null)
        .set(product.toMap());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    // Borrado lógico recomendado para no romper historial de ventas
    await _firestore.collection(_collection).doc(productId).update({
      'isActive': false,
    });
  }
}
