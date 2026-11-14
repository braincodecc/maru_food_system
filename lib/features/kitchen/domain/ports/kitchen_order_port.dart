import '../../../order/domain/entities/order_entity.dart'; // O puedes mapearlo a una entidad propia si prefieres aislamiento total

abstract class KitchenOrderPort {
  Future<List<OrderEntity>> getActiveKitchenOrders();
  Future<void> updateOrderStatusToPreparation(String orderId);
  Future<void> updateOrderStatusToReady(String orderId);
}