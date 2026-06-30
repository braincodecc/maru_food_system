  import 'package:flutter/foundation.dart';
  import '../models/product.dart';
  import '../models/cart_item.dart';

  class CartProvider with ChangeNotifier {
    // Lista interna de ítems del carrito
    final List<CartItem> _items = [];

    // Obtener la lista desde fuera (solo lectura)
    List<CartItem> get items => _items;

    // Obtener total general del carrito
    double get totalPrice {
      double total = 0.0;
      for (var item in _items) {
        total += item.total;
      }
      return total;
    }

    // Obtener total de unidades en el carrito
    int get totalItems {
      int total = 0;
      for (var item in _items) {
        total += item.quantity;
      }
      return total;
    }

    // Agregar producto al carrito
    void addProduct(Product product) {
      // Revisar si ya existe
      final index =
      _items.indexWhere((element) => element.product.id == product.id);

      if (index >= 0) {
        // Ya está → aumentar cantidad
        _items[index].quantity++;
      } else {
        // No está → agregar nuevo
        _items.add(CartItem(product: product));
      }

      notifyListeners(); // Actualizar UI
    }

    // Quitar 1 unidad del producto
    void decreaseProduct(Product product) {
      final index =
      _items.indexWhere((element) => element.product.id == product.id);

      if (index == -1) return;

      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }

    // Eliminar completamente un producto
    void removeProduct(Product product) {
      _items.removeWhere((item) => item.product.id == product.id);
      notifyListeners();
    }

    // Vaciar el carrito
    void clear() {
      _items.clear();
      notifyListeners();
    }
  }
