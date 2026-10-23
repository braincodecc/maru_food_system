import 'package:flutter/material.dart';
import '../datos/articulo_pedido_model.dart';
import '../datos/pedido_model.dart';
import '../datos/pedido_service.dart';
import 'flujo_venta_provider.dart';

/// [CarritoProvider] es la evolución híbrida de cart_provider.dart.
/// Gestiona los productos seleccionados y efectúa el cierre financiero de la venta.
class CarritoProvider with ChangeNotifier {
  final PedidoService _pedidoService = PedidoService();

  // Lista interna de productos en el carrito
  final List<ArticuloPedidoModel> _items = [];

  // Tasa de cambio por defecto (Este valor idealmente vendrá de un servicio de configuración/BCV)
  double _tasaCambio = 36.50;

  // Getters claros
  List<ArticuloPedidoModel> get items => _items;
  double get tasaCambio => _tasaCambio;

  void actualizarTasaCambio(double nuevaTasa) {
    _tasaCambio = nuevaTasa;
    notifyListeners();
  }

  // ==========================================
  // OPERACIONES DEL CARRITO (En caliente)
  // ==========================================

  void agregarProducto(ArticuloPedidoModel item) {
    // Si el producto ya existe en el carrito, sumamos la cantidad
    final index = _items.indexWhere(
      (element) => element.productId == item.productId,
    );
    if (index >= 0) {
      // Modificamos la cantidad en caliente y actualizamos el total
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
        totalUsd: _items[index].totalUsd + item.totalUsd,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removerProducto(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void incrementarCantidad(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      // Solo pasamos los parámetros que cambian, el resto se hereda automáticamente
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
        totalUsd: (_items[index].quantity + 1) * _items[index].priceUsd,
      );

      notifyListeners();
    }
  }

  void disminuirCantidad(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity - 1,
          totalUsd: (_items[index].quantity - 1) * _items[index].priceUsd,
        );
      } else {
        _items.removeAt(index); // Si llega a 0, se remueve automáticamente
      }
      notifyListeners();
    }
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }

  // ==========================================
  // CÁLCULOS MATEMÁTICOS EN TIEMPO REAL
  // ==========================================

  double get totalUsd {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.priceUsd * item.quantity),
    );
  }

  double get totalBs {
    return totalUsd * _tasaCambio;
  }

  /// Calcula la ganancia estimada de la venta (puedes adaptarlo según tus costos)
  double get profitUsd {
    // Ejemplo: Asumimos un margen general del 40% de ganancia, o puedes calcularlo por producto si tienes el costo
    return totalUsd * 0.40;
  }

  // ==========================================
  // CIERRE DE VENTA (Checkout Express)
  // ==========================================

  /// Procesa el pago final reuniendo los datos de las pantallas anteriores y mandando a Firestore
  // La clase FlujoVentaProvider no contine el campo ubicacionDespacho, por lo que es necesario crear en su modelo
  Future<void> despacharVentaExpress({
    required FlujoVentaProvider datosCliente,
    required String metodoPago,
    String? referenciaPago,
  }) async {
    if (_items.isEmpty) {
      throw Exception("No puedes despachar una venta con el carrito vacío.");
    }

    // Determinamos de forma inteligente si falta información para la auditoría nocturna
    // Si el nombre se quedó por defecto o no hay ubicación real de despacho, se marca como pendiente
    bool requiereRevisionNocturna =
        datosCliente.customerName == 'Cliente Express' ||
        datosCliente.customerLocation == null;

    // Construimos el PedidoModel optimizado (sin campos redundantes)
    final nuevoPedido = PedidoModel(
      id: '', // Firestore generará este ID automáticamente al guardarse
      customerName: datosCliente.customerName,
      customerPhone: datosCliente.customerPhone,
      customerLocation: datosCliente.customerLocation,
      orderType: datosCliente.customerLocation != null ? 'delivery' : 'pickup',
      paymentMethod: metodoPago,
      paymentReference: referenciaPago,
      exchangeRate: _tasaCambio,
      totalUsd: totalUsd,
      totalBs: totalBs,
      profitUsd: profitUsd,
      items: _items, // Clonamos la lista para congelar el estado
      status:
          'completed', // En caja express la venta se asume completada/pagada al momento
      createdAt: DateTime.now(),
      isPendingAdminEnrichment: requiereRevisionNocturna,
    );

    try {
      // Enviamos a la base de datos a través de nuestro servicio híbrido
      await _pedidoService.crearPedidoExpress(nuevoPedido);

      // Si todo sale bien, vaciamos el carrito local
      limpiarCarrito();
    } catch (e) {
      print("Error en CarritoProvider al procesar checkout: $e");
      rethrow;
    }
  }
}
