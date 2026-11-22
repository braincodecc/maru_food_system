// Importaciones del modulo de delivery
import '../data/adapters/delivery_order_adapter_impl.dart';
import '../domain/usecases/get_active_orders_usecase.dart';
import '../domain/usecases/mark_order_out_for_delivery_usecase.dart';
import '../domain/usecases/mark_order_complete_usecase.dart';
import '../presentation/providers/delivery_provider.dart';

// Importaciones del módulo de órdenes y finanzas
import 'package:maru_food_system/features/order/di/order_injector.dart';

DeliveryProvider createDeliveryProvider() {
  // 💡 Pides el caso de uso ya armado al módulo dueño (Order)
  final getDeliveryOrdersUseCase = createGetDeliveryOrdersUseCase();
  final updateOrderOperationalStatusUseCase = createUpdateOrderOperationalStatusUseCase();
  final updateOrderStatusUseCase = createUpdateOrderStatusUseCase();

  // Se lo pasas al adaptador de delivery
  final deliveryOrderAdapter = DeliveryOrderAdapterImpl(
    getDeliveryOrdersUseCase: getDeliveryOrdersUseCase,
    updateOrderOperationalStatusUseCase: updateOrderOperationalStatusUseCase,
    updateOrderStatusUseCase: updateOrderStatusUseCase,
  );

  return DeliveryProvider(
    getActiveOrdersUseCase: GetActiveOrdersUseCase(
      deliveryOrderPort: deliveryOrderAdapter,
    ),
    markOrderOutForDeliveryUsecase: MarkOrderOutForDeliveryUseCase(
      deliveryOrderPort: deliveryOrderAdapter,
    ),
    markOrderCompleteUsecase: MarkOrderCompleteUsecase(
      deliveryOrderPort: deliveryOrderAdapter,
    ),
  );
}
