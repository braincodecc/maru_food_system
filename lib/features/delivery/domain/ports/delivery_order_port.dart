import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

abstract class DeliveryOrderPort {
  Future<List<OrderEntity>> getActiveDeliveries();
  Future<void> startDelivery(String orderId);      // ready -> outForDelivery
  Future<void> completeDelivery(String orderId);   // outForDelivery -> delivered (y transiciona a completed)
}