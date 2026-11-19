import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetAdminOrdersUseCase {
  final OrderRepository _repository;

  GetAdminOrdersUseCase(this._repository);

  /// Obtiene todas las órdenes del sistema para el panel del administrador (Future List)
  Future<List<OrderEntity>> call() async {
    return await _repository.getAllOrders();
  }
}
