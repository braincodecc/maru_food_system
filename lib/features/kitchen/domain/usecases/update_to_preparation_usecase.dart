import '../../domain/ports/kitchen_order_port.dart';

class UpdateToPreparationUseCase {
  final KitchenOrderPort _kitchenOrderPort;

  UpdateToPreparationUseCase({required KitchenOrderPort kitchenOrderPort})
    : _kitchenOrderPort = kitchenOrderPort;

  Future<void> call(String orderId) async {
    await _kitchenOrderPort.updateOrderStatusToPreparation(orderId);
  }
}