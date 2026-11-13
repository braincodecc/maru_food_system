// features/kitchen/presentation/providers/kitchen_provider.dart
import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import '../../domain/usecases/get_kitchen_orders_usecase.dart';
import '../../domain/usecases/update_to_preparation_usecase.dart';
import '../../domain/usecases/mark_order_ready_usecase.dart';

class KitchenProvider extends ChangeNotifier {
  final GetKitchenOrdersUseCase _getKitchenOrdersUseCase;
  final UpdateToPreparationUseCase _updateToPreparationUseCase;
  final MarkOrderReadyUseCase _markOrderReadyUseCase;

  KitchenProvider({
    required GetKitchenOrdersUseCase getKitchenOrdersUseCase,
    required UpdateToPreparationUseCase updateToPreparationUseCase,
    required MarkOrderReadyUseCase markOrderReadyUseCase,
  })  : _getKitchenOrdersUseCase = getKitchenOrdersUseCase,
        _updateToPreparationUseCase = updateToPreparationUseCase,
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
      _orders = await _getKitchenOrdersUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startPreparation(String orderId) async {
    try {
      await _updateToPreparationUseCase(orderId);
      await loadKitchenOrders(); // Refrescamos lista
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsReady(String orderId) async {
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