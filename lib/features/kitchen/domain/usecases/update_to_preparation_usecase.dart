import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/repositories/order_repository.dart';

class UpdateToPreparationUseCase {
  final OrderRepository _orderRepository;

  UpdateToPreparationUseCase(this._orderRepository);

  Future<void> call(String orderId) async {
    await _orderRepository.updateOrderStatus(orderId, OrderStatus.inPreparation);
  }
}