import '../../../order/domain/usecases/get_kitchen_orders_usecase.dart'; // Un caso de uso liviano de órdenes
import '../../../order/domain/usecases/update_order_operational_status_usecase.dart'; // Un caso de uso liviano de órdenes
import '../../../order/domain/entities/order_status.enum.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/ports/kitchen_order_port.dart';

class KitchenOrderAdapterImpl implements KitchenOrderPort {
  final GetKitchenOrdersUseCase _getKitchenOrdersUseCase;
  final UpdateOrderOperationalStatusUseCase _updateOrderOperationalStatusUseCase;

  KitchenOrderAdapterImpl({
    required GetKitchenOrdersUseCase getKitchenOrdersUseCase,
    required UpdateOrderOperationalStatusUseCase updateOrderOperationalStatusUseCase,
  }) : _getKitchenOrdersUseCase = getKitchenOrdersUseCase,
       _updateOrderOperationalStatusUseCase = updateOrderOperationalStatusUseCase;

  @override
  Future<List<OrderEntity>> getActiveKitchenOrders() async {
    return await _getKitchenOrdersUseCase();
  }

  @override
  Future<void> markOrderStatusToPreparation(String orderId) async {
    await _updateOrderOperationalStatusUseCase(orderId, OrderStatus.inPreparation);
  }

  @override
  Future<void> markOrderStatusToReady(String orderId) async {
    await _updateOrderOperationalStatusUseCase(orderId, OrderStatus.ready);
  }
}
