import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;
  GetOrdersUseCase(this._repository);

  Future<List<OrderEntity>> forClient(String clientId) async {
    return await _repository.getOrdersForClient(clientId);
  }

  Future<List<OrderEntity>> all() async {
    return await _repository.getAllOrders();
  }
}