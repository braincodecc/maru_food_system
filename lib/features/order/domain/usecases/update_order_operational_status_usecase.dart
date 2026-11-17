import '../entities/order_status.enum.dart';
import '../repositories/order_repository.dart';

class UpdateOrderOperationalStatusUseCase {
  final OrderRepository _orderRepository;

  UpdateOrderOperationalStatusUseCase({
    required OrderRepository orderRepository,
  }) : _orderRepository = orderRepository;

  Future<void> call(String orderId, OrderStatus newStatus) async {
    await _orderRepository.updateOrderStatus(orderId, newStatus);
  }
}
