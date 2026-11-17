import '../ports/delivery_order_port.dart';

class MarkOrderCompleteUsecase {
  final DeliveryOrderPort _deliveryOrderPort;

  MarkOrderCompleteUsecase({required DeliveryOrderPort deliveryOrderPort})
      : _deliveryOrderPort = deliveryOrderPort;

  Future<void> call(String orderId) async {
    await _deliveryOrderPort.markOrderStatusToCompleted(orderId);
  }
}