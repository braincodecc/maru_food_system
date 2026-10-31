import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderReservationUsecase {
  final OrderRepository _repository;
  CreateOrderReservationUsecase(this._repository);

  Future<String?> call(OrderEntity order) async {
    return await _repository.createOrderReservation(order);
  }
}