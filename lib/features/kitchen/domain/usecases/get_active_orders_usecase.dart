import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import '../../domain/ports/kitchen_order_port.dart';

class GetActiveOrdersUseCase {
  final KitchenOrderPort _kitchenOrderPort;

  GetActiveOrdersUseCase({required KitchenOrderPort kitchenOrderPort})
    : _kitchenOrderPort = kitchenOrderPort;

  Future<List<OrderEntity>> call() async {
    return _kitchenOrderPort.getActiveKitchenOrders();
  }
}