import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import '../../domain/ports/kitchen_order_port.dart';

class GetKitchenOrdersUseCase {
  final KitchenOrderPort _kitchenOrderPort;

  GetKitchenOrdersUseCase({required KitchenOrderPort kitchenOrderPort})
    : _kitchenOrderPort = kitchenOrderPort;

  Future<List<OrderEntity>> call() async {
    return _kitchenOrderPort.getActiveKitchenOrders();
  }
}