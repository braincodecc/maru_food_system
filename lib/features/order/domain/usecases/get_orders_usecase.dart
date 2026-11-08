import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  /// Obtiene el historial de órdenes de un cliente (Future List)
  Future<List<OrderEntity>> forClient(String clientId) async {
    return await _repository.getOrdersForClient(clientId);
  }

  /// Obtiene todas las órdenes del sistema para el panel del administrador (Future List)
  Future<List<OrderEntity>> all() async {
    return await _repository.getAllOrders();
  }

  /// Observa en tiempo real la única orden activa del cliente (Stream)
  Stream<OrderEntity?> activeForClient(String clientId) {
    return _repository.watchActiveOrder(clientId);
  }
}
