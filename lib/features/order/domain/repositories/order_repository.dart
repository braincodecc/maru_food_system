import '../entities/order_entity.dart';
import '../entities/order_status.enum.dart';

abstract class OrderRepository {
  Future<String?> createOrderWithStockReservation(OrderEntity order);
  Future<void> submitOrderPaymentReference(String orderId, String paymentReference, String clientPhone);
  Future<List<OrderEntity>> getOrdersForClient(String clientId);
  Future<List<OrderEntity>> getAllOrders(); // Para el panel del administrador
  Future<OrderEntity?> getOrderById(String orderId); // Obtener detalles de una orden específica
  Future<bool> hasActiveOrder(String clientId); // Verificar si hay un pedido activo
  Stream<OrderEntity?> watchActiveOrder(String clientId);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}