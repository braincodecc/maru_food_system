import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import '../ports/delivery_order_port.dart';

class GetActiveOrdersUseCase {
  final DeliveryOrderPort _deliveryOrderPort;

  GetActiveOrdersUseCase({required DeliveryOrderPort deliveryOrderPort})
      : _deliveryOrderPort = deliveryOrderPort;

  Future<List<OrderEntity>> call() async {
    return _deliveryOrderPort.getActiveDeliveryOrders();
  }
}