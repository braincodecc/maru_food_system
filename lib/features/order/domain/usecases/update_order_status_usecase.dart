import '../entities/order_status.enum.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;
  UpdateOrderStatusUseCase(this._repository);

  Future<void> call(String orderId, OrderStatus newStatus) async {
    await _repository.updateOrderStatus(orderId, newStatus);
  }
}