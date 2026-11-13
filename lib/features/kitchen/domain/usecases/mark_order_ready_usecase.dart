import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/repositories/order_repository.dart';

class MarkOrderReadyUseCase {
  final OrderRepository _orderRepository;

  MarkOrderReadyUseCase(this._orderRepository);

  Future<void> call(String orderId) async {
    // Cambia el estado a 'ready' (Listo en cocina)
    await _orderRepository.updateOrderStatus(orderId, OrderStatus.ready);
  }
}