import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';

abstract class AdminOrderPort {
  Future<List<OrderEntity>> getOrders();
  Future<void> changeStatus(String orderId, OrderStatus newStatus);
  Future<String?> reserveOrder({
    required String clientId,
    required bool isDelivery,
    required double totalAmount,
    required List<OrderItemEntity> items,
  });
  Future<void> confirmPurchase({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
    required bool isDelivery,
  });
}
