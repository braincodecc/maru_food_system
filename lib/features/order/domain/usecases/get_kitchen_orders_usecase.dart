import '../../../order/domain/repositories/order_repository.dart';
import '../../../order/domain/entities/order_status.enum.dart';
import '../../../order/domain/entities/order_entity.dart';

class GetKitchenOrdersUseCase {
  final OrderRepository _orderRepository;

  GetKitchenOrdersUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  Future<List<OrderEntity>> call() async {
    final allOrders = await _orderRepository.getAllOrders();
    // Filtramos exclusivamente lo que le importa a la cocina
    return allOrders.where((order) {
      return order.status == OrderStatus.approved ||
          order.status == OrderStatus.inPreparation ||
          order.status == OrderStatus.ready;
    }).toList();
  }
}
