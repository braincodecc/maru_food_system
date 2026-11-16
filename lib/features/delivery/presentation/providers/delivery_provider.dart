import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_delivery_orders_usecase.dart';
import '../../domain/usecases/start_delivery_usecase.dart';
import '../../domain/usecases/complete_delivery_usecase.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

class DeliveryProvider extends ChangeNotifier {
  final GetDeliveryOrdersUseCase _getDeliveryOrdersUseCase;
  final StartDeliveryUseCase _startDeliveryUseCase;
  final CompleteDeliveryUseCase _completeDeliveryUseCase;

  DeliveryProvider({
    required GetDeliveryOrdersUseCase getDeliveryOrdersUseCase,
    required StartDeliveryUseCase startDeliveryUseCase,
    required CompleteDeliveryUseCase completeDeliveryUseCase,
  })  : _getDeliveryOrdersUseCase = getDeliveryOrdersUseCase,
        _startDeliveryUseCase = startDeliveryUseCase,
        _completeDeliveryUseCase = completeDeliveryUseCase;

  List<OrderEntity> _deliveries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderEntity> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDeliveries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deliveries = await _getDeliveryOrdersUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTrip(String orderId) async {
    try {
      await _startDeliveryUseCase(orderId);
      await loadDeliveries();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> finishDelivery(String orderId) async {
    try {
      await _completeDeliveryUseCase(orderId);
      await loadDeliveries();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}