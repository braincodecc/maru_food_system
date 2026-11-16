import '../ports/delivery_order_port.dart';

class CompleteDeliveryUseCase {
  final DeliveryOrderPort _deliveryOrderPort;

  CompleteDeliveryUseCase({required DeliveryOrderPort deliveryOrderPort})
      : _deliveryOrderPort = deliveryOrderPort;

  Future<void> call(String orderId) async {
    await _deliveryOrderPort.completeDelivery(orderId);
  }
}