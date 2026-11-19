import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';

abstract class AdminOrderPort {
  Future<List<OrderEntity>> getOrders();
  Future<void> changeStatus(String orderId, OrderStatus newStatus);
}