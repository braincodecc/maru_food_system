import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderReservationUsecase {
  final OrderRepository _repository;
  CreateOrderReservationUsecase(this._repository);

  Future<String?> call(OrderEntity order) async {
    // 1. APLICAMOS LA REGLA DE NEGOCIO EN EL DOMINIO
    final hasActive = await _repository.hasActiveOrder(order.clientId);
    if (hasActive) {
      throw Exception(
        'Ya tienes un pedido en proceso. Debes esperar a que sea entregado o rechazado.',
      );
    }

    // 2. Si pasa la regla, procedemos a la reserva de stock y creación
    return await _repository.createOrderWithStockReservation(order);
  }
}