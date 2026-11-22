import '../../../order/domain/usecases/get_delivery_orders_usecase.dart'; // Un caso de uso liviano de órdenes
import '../../../order/domain/usecases/update_order_operational_status_usecase.dart'; // Un caso de uso liviano de órdenes
import '../../../order/domain/usecases/update_order_status_usecase.dart';
import '../../../order/domain/entities/order_status.enum.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/ports/delivery_order_port.dart';

class DeliveryOrderAdapterImpl implements DeliveryOrderPort {
  final GetDeliveryOrdersUseCase _getDeliveryOrdersUseCase;
  final UpdateOrderOperationalStatusUseCase
  _updateOrderOperationalStatusUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  DeliveryOrderAdapterImpl({
    required GetDeliveryOrdersUseCase getDeliveryOrdersUseCase,
    required UpdateOrderOperationalStatusUseCase
    updateOrderOperationalStatusUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _getDeliveryOrdersUseCase = getDeliveryOrdersUseCase,
       _updateOrderOperationalStatusUseCase =
           updateOrderOperationalStatusUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase;

  @override
  Future<List<OrderEntity>> getActiveDeliveryOrders() async {
    return _getDeliveryOrdersUseCase();
  }

  @override
  Future<void> markOrderStatusToOutForDelivery(String orderId) async {
    await _updateOrderOperationalStatusUseCase(
      orderId,
      OrderStatus.outForDelivery,
    );
  }

  @override
  Future<void> markOrderStatusToCompleted(String orderId) async {
    await _updateOrderOperationalStatusUseCase(orderId, OrderStatus.delivered);
    await _updateOrderStatusUseCase(orderId, OrderStatus.completed);
  }
}
