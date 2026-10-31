import '../entities/order_entity.dart';
import '../entities/order_status.enum.dart';

abstract class OrderRepository {
  Future<String?> createOrderReservation(OrderEntity order);
  Future<void> submitPaymentReference(String orderId, String paymentReference, String clientPhone);
  Future<List<OrderEntity>> getOrdersForClient(String clientId);
  Future<List<OrderEntity>> getAllOrders(); // Para el panel del administrador
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}