import '../ports/delivery_order_port.dart';

class StartDeliveryUseCase {
  final DeliveryOrderPort _deliveryOrderPort;

  StartDeliveryUseCase({required DeliveryOrderPort deliveryOrderPort})
      : _deliveryOrderPort = deliveryOrderPort;

  Future<void> call(String orderId) async {
    await _deliveryOrderPort.startDelivery(orderId);
  }
}