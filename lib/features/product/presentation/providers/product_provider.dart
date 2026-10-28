import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_active_products_usecase.dart';
import '../../domain/usecases/validate_cart_stock_usecase.dart';
import '../../domain/usecases/process_checkout_usecase.dart';
import '../../domain/usecases/save_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';

class ProductProvider extends ChangeNotifier {
  final GetActiveProductsUseCase _getActiveProductsUseCase;
  final ValidateCartStockUseCase _validateCartStockUseCase;
  final ProcessCheckoutUseCase _processCheckoutUseCase;
  final SaveProductUseCase _saveProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  ProductProvider({
    required GetActiveProductsUseCase getActiveProductsUseCase,
    required ValidateCartStockUseCase validateCartStockUseCase,
    required ProcessCheckoutUseCase processCheckoutUseCase,
    required SaveProductUseCase saveProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  }) : _getActiveProductsUseCase = getActiveProductsUseCase,
       _validateCartStockUseCase = validateCartStockUseCase,
       _processCheckoutUseCase = processCheckoutUseCase,
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

  /// 4. Validar stock en servidor justo antes de confirmar el checkout
  /// Recibe un mapa con [productId: cantidadDeseada]
  Future<bool> validateCheckout(Map<String, int> cartItems) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final problematicProducts = await _validateCartStockUseCase(cartItems);

      if (problematicProducts.isNotEmpty) {
        final names = problematicProducts.map((p) => p.name).join(', ');
        _errorMessage =
            'Lo sentimos, no hay suficiente stock disponible para: $names';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al validar el stock: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 5. Confirmar compra (descuenta stock en Firestore de forma atómica)
  Future<bool> checkout(Map<String, int> cartItems) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validamos una última vez antes de procesar
      bool isValid = await validateCheckout(cartItems);
      if (!isValid) return false;

      // Procesamos el pago y descuento atómico en el servidor
      await _processCheckoutUseCase(cartItems);

      // Recargamos los productos para refrescar los stocks reales
      await loadActiveProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Error al procesar la compra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 6. Guardar un producto (nuevo o existente)
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

  /// 7. Eliminar un producto
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
