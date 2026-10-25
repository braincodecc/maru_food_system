import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  /// Obtiene todos los productos con isActive == true desde Firestore
  Future<List<ProductModel>> getActiveProducts();

  /// Obtiene todos los productos (activos e inactivos) para la vista del administrador
  Future<List<ProductModel>> getAllProductsForAdmin();

  /// Obtiene un producto individual por su ID
  Future<ProductModel?> getProductById(String productId);

  /// Ejecuta una transacción atómica en Firestore para validar y descontar el stock
  /// Recibe un mapa de IDs de productos y las cantidades que se desean comprar.
  /// Lanza una excepción si algún producto no tiene stock suficiente.
  Future<void> processCheckoutTransaction(Map<String, int> cartItems);

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
        .map((doc) => ProductModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<ProductModel>> getAllProductsForAdmin() async {
    final querySnapshot = await _firestore.collection(_collection).get();

    return querySnapshot.docs
        .map((doc) => ProductModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection(_collection).doc(productId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ProductModel.fromJson(doc.id, doc.data()!);
  }

  @override
  Future<void> processCheckoutTransaction(Map<String, int> cartItems) async {
    // Usamos una transacción de Firestore para garantizar consistencia absoluta de inventario
    await _firestore.runTransaction((transaction) async {
      // 1. Fase de Lectura y Validación de stock para todos los ítems del carrito
      final Map<DocumentReference, int> productsToUpdate = {};
      final Map<String, DocumentSnapshot> snapshots = {};

      for (var entry in cartItems.entries) {
        final productId = entry.key;
        final requestedQuantity = entry.value;

        final docRef = _firestore.collection(_collection).doc(productId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('El producto con ID $productId ya no existe en el sistema.');
        }

        final currentStock = snapshot.data()?['stock'] ?? 0;
        final productName = snapshot.data()?['name'] ?? 'Producto';

        if (currentStock < requestedQuantity) {
          throw Exception(
            'Stock insuficiente para "$productName". Disponible: $currentStock, solicitado: $requestedQuantity.',
          );
        }

        snapshots[productId] = snapshot;
        productsToUpdate[docRef] = currentStock - requestedQuantity;
      }

      // 2. Fase de Escritura (Descuento atómico del stock)
      for (var entry in productsToUpdate.entries) {
        transaction.update(entry.key, {'stock': entry.value});
      }
    });
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id.isNotEmpty ? product.id : null)
        .set(product.toJson());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .update(product.toJson());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    // Borrado lógico recomendado para no romper historial de ventas
    await _firestore.collection(_collection).doc(productId).update({
      'isActive': false,
    });
  }
}