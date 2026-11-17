import '../../domain/ports/kitchen_order_port.dart';

class MarkOrderPreparationUseCase {
  final KitchenOrderPort _kitchenOrderPort;

  MarkOrderPreparationUseCase({required KitchenOrderPort kitchenOrderPort})
    : _kitchenOrderPort = kitchenOrderPort;

  Future<void> call(String orderId) async {
    await _kitchenOrderPort.markOrderStatusToPreparation(orderId);
  }
}