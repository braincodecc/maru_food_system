import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import '../../domain/ports/admin_order_port.dart';

class AdminOrderProvider extends ChangeNotifier {
  final AdminOrderPort _adminOrderPort;

  AdminOrderProvider({required AdminOrderPort adminOrderPort})
    : _adminOrderPort = adminOrderPort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OrderEntity> _orders = [];
  List<OrderEntity> get orders => _orders;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _adminOrderPort.getOrders();
    } catch (e) {
      _errorMessage = 'Error al cargar los productos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el estado de un pedido (aprovado, Rechazar, etc.) y recarga la lista correspondiente
  Future<bool> changeOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    bool isAdmin = false,
    String? clientId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminOrderPort.changeStatus(orderId, newStatus);
      await loadOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createOrderReservation({
    required String clientId,
    required bool isDelivery,
    required double totalAmount,
    required List<OrderItemEntity> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderId = await _adminOrderPort.reserveOrder(
        clientId: clientId,
        isDelivery: isDelivery,
        totalAmount: totalAmount,
        items: items,
      );
      await loadOrders();
      return orderId;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmOrderPurchase({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
    required bool isDelivery,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminOrderPort.confirmPurchase(
        orderId: orderId,
        paymentReference: paymentReference,
        clientPhone: clientPhone,
        isDelivery: isDelivery,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
