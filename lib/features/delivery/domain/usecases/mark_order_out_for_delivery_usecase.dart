import '../ports/delivery_order_port.dart';

class MarkOrderOutForDeliveryUseCase {
  final DeliveryOrderPort _deliveryOrderPort;

  MarkOrderOutForDeliveryUseCase({required DeliveryOrderPort deliveryOrderPort})
      : _deliveryOrderPort = deliveryOrderPort;

  Future<void> call(String orderId) async {
    await _deliveryOrderPort.markOrderStatusToOutForDelivery(orderId);
  }
}