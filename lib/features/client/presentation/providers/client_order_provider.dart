import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';
import '../../domain/ports/client_order_port.dart';

class ClientOrderProvider extends ChangeNotifier {
  final ClientOrderPort _clientOrderPort;

  ClientOrderProvider({required ClientOrderPort clientOrderPort})
      : _clientOrderPort = clientOrderPort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      return await _clientOrderPort.reserveOrder(
        clientId: clientId,
        isDelivery: isDelivery,
        totalAmount: totalAmount,
        items: items,
      );
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
      await _clientOrderPort.confirmPurchase(
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

  Stream<OrderEntity?> watchActiveOrder(String clientId) {
    return _clientOrderPort.watchActiveOrder(clientId);
  }
}