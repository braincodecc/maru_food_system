import '../../../order/domain/repositories/order_repository.dart';
import '../../../order/domain/entities/order_status.enum.dart';
import '../../../order/domain/entities/order_entity.dart';

class GetDeliveryOrdersUseCase {
  final OrderRepository _orderRepository;

  GetDeliveryOrdersUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  Future<List<OrderEntity>> call() async {
    final allOrders = await _orderRepository.getAllOrders();
    // Filtramos exclusivamente lo que le importa para el repartidor: pedidos de delivery que estén listos o en camino
    return allOrders.where((order) {
      return order.isDelivery &&
          (order.status == OrderStatus.ready ||
              order.status == OrderStatus.outForDelivery);
    }).toList();
  }
}
