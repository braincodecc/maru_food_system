// features/admin/presentation/providers/admin_product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';
import '../../domain/ports/admin_product_port.dart';

class AdminProductProvider extends ChangeNotifier {
  final AdminProductPort _adminProductPort;

  AdminProductProvider({required AdminProductPort adminProductPort})
      : _adminProductPort = adminProductPort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ProductEntity> _products = [];
  List<ProductEntity> get products => _products;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _adminProductPort.getProducts();
    } catch (e) {
      _errorMessage = 'Error al cargar los productos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProduct(ProductEntity product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminProductPort.saveProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar el producto: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminProductPort.deleteProduct(productId);
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar el producto: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}