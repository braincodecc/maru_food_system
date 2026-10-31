import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_active_products_usecase.dart';
import '../../domain/usecases/save_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';

class ProductProvider extends ChangeNotifier {
  final GetActiveProductsUseCase _getActiveProductsUseCase;
  final SaveProductUseCase _saveProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  ProductProvider({
    required GetActiveProductsUseCase getActiveProductsUseCase,
    required SaveProductUseCase saveProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  }) : _getActiveProductsUseCase = getActiveProductsUseCase,
       _saveProductUseCase = saveProductUseCase,
       _deleteProductUseCase = deleteProductUseCase;

  // Estados
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Catálogo principal (Menú activo)
  List<ProductEntity> _activeProducts = [];
  List<ProductEntity> get activeProducts => _activeProducts;

  // Caché temporal en memoria del stock mientras el cliente edita su carrito
  // Clave: ProductId, Valor: Stock disponible temporal en memoria
  final Map<String, int> _localStockCache = {};

  /// 1. Cargar el menú activo (se llama al abrir la pantalla de compras)
  Future<void> loadActiveProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeProducts = await _getActiveProductsUseCase();

      // Inicializamos la caché local con los valores reales del servidor
      _localStockCache.clear();
      for (var product in _activeProducts) {
        _localStockCache[product.id] = product.stock;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar el menú: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Obtener el stock disponible en caché para un producto (evita lecturas a Firestore)
  int getCachedStock(String productId) {
    return _localStockCache[productId] ?? 0;
  }

  /// 3. Simular descuento local en el carrito (Caché en memoria del cliente)
  void updateLocalCacheAfterAddToCart(String productId, int quantityChange) {
    if (_localStockCache.containsKey(productId)) {
      final currentCache = _localStockCache[productId]!;
      _localStockCache[productId] = currentCache + quantityChange;
      notifyListeners();
    }
  }

  /// 4. Guardar un producto (nuevo o existente)
  Future<bool> saveProduct(ProductEntity product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _saveProductUseCase(product);
      // Recargamos el catálogo para que la UI refleje el cambio de inmediato
      await loadActiveProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar el producto: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 5. Eliminar un producto
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteProductUseCase(productId);
      await loadActiveProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el producto: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
