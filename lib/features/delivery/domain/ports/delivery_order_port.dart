import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

abstract class DeliveryOrderPort {
  Future<List<OrderEntity>> getActiveDeliveryOrders();
  Future<void> markOrderStatusToOutForDelivery(String orderId);      // ready -> outForDelivery
  Future<void> markOrderStatusToCompleted(String orderId);   // outForDelivery -> delivered (y transiciona a completed)
}