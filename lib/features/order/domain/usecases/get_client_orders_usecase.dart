import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetClientOrdersUseCase {
  final OrderRepository _repository;

  GetClientOrdersUseCase(this._repository);

  /// Obtiene el historial de órdenes de un cliente (Future List)
  Future<List<OrderEntity>> call(String clientId) async {
    return await _repository.getOrdersForClient(clientId);
  }

  /// Observa en tiempo real la única orden activa del cliente (Stream)
  Stream<OrderEntity?> active(String clientId) {
    return _repository.watchActiveOrder(clientId);
  }
}
