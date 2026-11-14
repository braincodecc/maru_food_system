import '../../../order/domain/repositories/order_repository.dart';
import '../../../order/domain/entities/order_status.enum.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/ports/kitchen_order_port.dart';

class KitchenOrderAdapterImpl implements KitchenOrderPort {
  final OrderRepository _orderRepository;

  KitchenOrderAdapterImpl({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  @override
  Future<List<OrderEntity>> getActiveKitchenOrders() async {
    final allOrders = await _orderRepository.getAllOrders();
    // Filtramos exclusivamente lo que le importa a la cocina
    return allOrders.where((order) {
      return order.status == OrderStatus.approved ||
          order.status == OrderStatus.inPreparation ||
          order.status == OrderStatus.ready;
    }).toList();
  }

  @override
  Future<void> updateOrderStatusToPreparation(String orderId) async {
    await _orderRepository.updateOrderStatus(
      orderId,
      OrderStatus.inPreparation,
    );
  }

  @override
  Future<void> updateOrderStatusToReady(String orderId) async {
    await _orderRepository.updateOrderStatus(orderId, OrderStatus.ready);
  }
}
