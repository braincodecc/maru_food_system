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
  Future<void> processCheckoutTransaction(Map<String, int> cartItems) async {
    // Usamos una transacción de Firestore para garantizar consistencia absoluta de inventario
    await _firestore.runTransaction((transaction) async {
      // Mapas para almacenar las referencias y los nuevos valores calculados
      final Map<DocumentReference, dynamic> updatesToExecute = {};

      // Acumuladores temporales para calcular el consumo total de ingredientes si se piden varios platos iguales
      final Map<String, double> requiredIngredientsDelta = {};

      // 1. Fase de Lectura y Validación exhaustiva (Productos y Recetas/Ingredientes)
      for (var entry in cartItems.entries) {
        final productId = entry.key;
        final requestedQuantity = entry.value;

        final productDocRef = _firestore.collection(_collection).doc(productId);
        final productSnapshot = await transaction.get(productDocRef);

        if (!productSnapshot.exists || productSnapshot.data() == null) {
          throw Exception(
            'El producto con ID $productId ya no existe en el sistema.',
          );
        }

        final productData = productSnapshot.data()!;
        final productName = productData['name'] ?? 'Producto';
        final productType = productData['type'] ?? 'comprado';
        final currentStock = productData['stock'] ?? 0;

        // Validación de stock del producto en sí
        if (currentStock < requestedQuantity) {
          throw Exception(
            'Stock insuficiente para "$productName". Disponible: $currentStock, solicitado: $requestedQuantity.',
          );
        }

        // Programamos el descuento del producto principal
        updatesToExecute[productDocRef] = {
          'stock': currentStock - requestedQuantity,
        };

        // Si el producto es FABRICADO, debemos validar y descontar sus ingredientes de la colección 'ingredients'
        if (productType == 'fabricado') {
          final List<dynamic> recipeList = productData['recipe'] ?? [];

          for (var recipeItem in recipeList) {
            final ingredientId = recipeItem['ingredientId'];
            final double quantityPerUnit =
                (recipeItem['quantityRequired'] ?? 0.0).toDouble();
            final double totalNeededForThisItem =
                quantityPerUnit * requestedQuantity;

            // Acumulamos por si el carrito incluye varios productos que usan el mismo ingrediente
            requiredIngredientsDelta[ingredientId] =
                (requiredIngredientsDelta[ingredientId] ?? 0.0) +
                totalNeededForThisItem;
          }
        }
      }

      // 2. Validación y lectura de los Ingredientes requeridos en el almacén
      for (var entry in requiredIngredientsDelta.entries) {
        final ingredientId = entry.key;
        final totalNeeded = entry.value;

        final ingredientDocRef = _firestore
            .collection('ingredients')
            .doc(ingredientId);
        final ingredientSnapshot = await transaction.get(ingredientDocRef);

        if (!ingredientSnapshot.exists || ingredientSnapshot.data() == null) {
          throw Exception(
            'Un ingrediente requerido de la receta ya no existe en el almacén.',
          );
        }

        final ingredientData = ingredientSnapshot.data()!;
        final ingredientName = ingredientData['name'] ?? 'Insumo';
        final double currentIngredientStock = (ingredientData['stock'] ?? 0.0)
            .toDouble();

        // Validamos si hay suficiente materia prima en el almacén
        if (currentIngredientStock < totalNeeded) {
          throw Exception(
            'Almacén insuficiente de "$ingredientName". Disponible: $currentIngredientStock, necesario: $totalNeeded.',
          );
        }

        // Programamos el descuento atómico en la colección de ingredientes
        updatesToExecute[ingredientDocRef] = {
          'stock': currentIngredientStock - totalNeeded,
        };
      }

      // 3. Fase de Escritura (Ejecución atómica de todas las actualizaciones juntas)
      for (var entry in updatesToExecute.entries) {
        transaction.update(entry.key, entry.value);
      }
    });
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
