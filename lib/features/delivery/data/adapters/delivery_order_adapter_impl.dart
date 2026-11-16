import '../../../order/domain/repositories/order_repository.dart';
import '../../../order/domain/usecases/update_order_status_usecase.dart';
import '../../../order/domain/entities/order_status.enum.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/ports/delivery_order_port.dart';

class DeliveryOrderAdapterImpl implements DeliveryOrderPort {
  final OrderRepository _orderRepository;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  DeliveryOrderAdapterImpl({
    required OrderRepository orderRepository,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _orderRepository = orderRepository,
       _updateOrderStatusUseCase = updateOrderStatusUseCase;

  @override
  Future<List<OrderEntity>> getActiveDeliveries() async {
    final allOrders = await _orderRepository.getAllOrders();
    // Filtramos solo las que son delivery y están listas o en ruta
    return allOrders.where((order) {
      return order.isDelivery &&
          (order.status == OrderStatus.ready ||
              order.status == OrderStatus.outForDelivery);
    }).toList();
  }

  @override
  Future<void> startDelivery(String orderId) async {
    await _updateOrderStatusUseCase.call(orderId, OrderStatus.outForDelivery);
  }

  @override
  Future<void> completeDelivery(String orderId) async {
    await _updateOrderStatusUseCase.call(orderId, OrderStatus.delivered);
    await _updateOrderStatusUseCase.call(orderId, OrderStatus.completed);
  }
}
