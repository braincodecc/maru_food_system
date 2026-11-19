import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';

abstract class ClientOrderPort {
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

  Stream<OrderEntity?> watchActiveOrder(String clientId);
}