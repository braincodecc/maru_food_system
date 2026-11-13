import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/repositories/order_repository.dart';

class StartDeliveryUseCase {
  final OrderRepository _orderRepository;

  StartDeliveryUseCase(this._orderRepository);

  Future<void> call(String orderId) async {
    // Pasa la orden a camino al cliente
    await _orderRepository.updateOrderStatus(orderId, OrderStatus.outForDelivery);
  }
}