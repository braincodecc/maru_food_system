import '../../domain/ports/kitchen_order_port.dart';

class MarkOrderReadyUseCase {
  final KitchenOrderPort _kitchenOrderPort;

  MarkOrderReadyUseCase({required KitchenOrderPort kitchenOrderPort})
    : _kitchenOrderPort = kitchenOrderPort;

  Future<void> call(String orderId) async {
    await _kitchenOrderPort.updateOrderStatusToReady(orderId);
  }
}
