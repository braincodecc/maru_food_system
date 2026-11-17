import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import '../../domain/usecases/get_active_orders_usecase.dart';
import '../../domain/usecases/mark_order_preparation_usecase.dart';
import '../../domain/usecases/mark_order_ready_usecase.dart';

class KitchenProvider extends ChangeNotifier {
  final GetActiveOrdersUseCase _getActiveOrdersUseCase;
  final MarkOrderPreparationUseCase _markOrderPreparationUseCase;
  final MarkOrderReadyUseCase _markOrderReadyUseCase;

  KitchenProvider({
    required GetActiveOrdersUseCase getActiveOrdersUseCase,
    required MarkOrderPreparationUseCase markOrderPreparationUseCase,
    required MarkOrderReadyUseCase markOrderReadyUseCase,
  })  : _getActiveOrdersUseCase = getActiveOrdersUseCase,
        _markOrderPreparationUseCase = markOrderPreparationUseCase,
        _markOrderReadyUseCase = markOrderReadyUseCase;

  List<OrderEntity> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderEntity> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadKitchenOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _getActiveOrdersUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsOrderInPreparation(String orderId) async {
    try {
      await _markOrderPreparationUseCase(orderId);
      await loadKitchenOrders(); // Refrescamos lista
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsOrderReady(String orderId) async {
    try {
      await _markOrderReadyUseCase(orderId);
      await loadKitchenOrders(); // Refrescamos lista
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}