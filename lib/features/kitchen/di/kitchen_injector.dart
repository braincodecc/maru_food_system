// Importaciones del módulo local de cocina
import '../data/adapters/kitchen_order_adapter_impl.dart';
import '../domain/usecases/get_active_orders_usecase.dart';
import '../domain/usecases/mark_order_ready_usecase.dart';
import '../domain/usecases/mark_order_preparation_usecase.dart';
import '../presentation/providers/kitchen_provider.dart';

// Importamos las fábricas públicas del módulo de órdenes
import 'package:maru_food_system/features/order/di/order_injector.dart';

KitchenProvider createKitchenProvider() {
  // Solicitamos los casos de uso ya listos al módulo dueño (Order)
  final getKitchenOrdersUseCase = createGetKitchenOrdersUseCase();
  final updateOrderOperationalStatusUseCase = createUpdateOrderOperationalStatusUseCase();

  // Creamos el adaptador de la cocina inyectando los casos de uso
  final kitchenOrderAdapter = KitchenOrderAdapterImpl(
    getKitchenOrdersUseCase: getKitchenOrdersUseCase,
    updateOrderOperationalStatusUseCase: updateOrderOperationalStatusUseCase,
  );

  final getActiveOrdersUseCase = GetActiveOrdersUseCase(kitchenOrderPort: kitchenOrderAdapter);
  final markOrderReadyUseCase = MarkOrderReadyUseCase(kitchenOrderPort: kitchenOrderAdapter);
    final markOrderPreparationUseCase = MarkOrderPreparationUseCase(kitchenOrderPort: kitchenOrderAdapter);

  return KitchenProvider(
    getActiveOrdersUseCase: getActiveOrdersUseCase,
    markOrderReadyUseCase: markOrderReadyUseCase,
    markOrderPreparationUseCase: markOrderPreparationUseCase,
  );
}