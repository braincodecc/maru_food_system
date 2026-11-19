import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';
import '../../domain/ports/client_product_port.dart';

class ClientProductProvider extends ChangeNotifier {
  final ClientProductPort _clientProductPort;

  ClientProductProvider({required ClientProductPort clientProductPort})
      : _clientProductPort = clientProductPort;

  // Estados
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Catálogo activo para el cliente
  List<ProductEntity> _activeProducts = [];
  List<ProductEntity> get activeProducts => _activeProducts;

  // Caché temporal en memoria del stock mientras el cliente edita su carrito
  final Map<String, int> _localStockCache = {};

  /// 1. Cargar el menú activo
  Future<void> loadActiveProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeProducts = await _clientProductPort.getActiveProducts();

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

  /// 2. Obtener el stock disponible en caché
  int getCachedStock(String productId) {
    return _localStockCache[productId] ?? 0;
  }

  /// 3. Simular descuento local en el carrito (Caché en memoria)
  void updateLocalCacheAfterAddToCart(String productId, int quantityChange) {
    if (_localStockCache.containsKey(productId)) {
      final currentCache = _localStockCache[productId]!;
      _localStockCache[productId] = currentCache + quantityChange;
      notifyListeners();
    }
  }
}