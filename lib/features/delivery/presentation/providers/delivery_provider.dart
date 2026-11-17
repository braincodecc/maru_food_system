import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_active_orders_usecase.dart';
import '../../domain/usecases/mark_order_out_for_delivery_usecase.dart';
import '../../domain/usecases/mark_order_complete_usecase.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

class DeliveryProvider extends ChangeNotifier {
  final GetActiveOrdersUseCase _getActiveOrdersUseCase;
  final MarkOrderOutForDeliveryUseCase _markOrderDeliveryUsecase;
  final MarkOrderCompleteUsecase _markOrderCompleteUsecase;

  DeliveryProvider({
    required GetActiveOrdersUseCase getActiveOrdersUseCase,
    required MarkOrderOutForDeliveryUseCase markOrderOutForDeliveryUsecase,
    required MarkOrderCompleteUsecase markOrderCompleteUsecase,
  })  : _getActiveOrdersUseCase = getActiveOrdersUseCase,
        _markOrderDeliveryUsecase = markOrderOutForDeliveryUsecase,
        _markOrderCompleteUsecase = markOrderCompleteUsecase;

  List<OrderEntity> _deliveries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderEntity> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDeliveryOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deliveries = await _getActiveOrdersUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsOrderOutForDelivery(String orderId) async {
    try {
      await _markOrderDeliveryUsecase(orderId);
      await loadDeliveryOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsOrderCompleted(String orderId) async {
    try {
      await _markOrderCompleteUsecase(orderId);
      await loadDeliveryOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}