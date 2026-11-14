// Importaciones del modulo de cocina
import '../data/adapters/kitchen_order_adapter_impl.dart';
import '../domain/usecases/get_kitchen_orders_usecase.dart';
import '../domain/usecases/update_to_preparation_usecase.dart';
import '../domain/usecases/mark_order_ready_usecase.dart';
import '../presentation/providers/kitchen_provider.dart';

// Importaciones del modulo de orden
import 'package:maru_food_system/features/order/data/datasources/order_remote_datasource.dart';
import 'package:maru_food_system/features/order/data/repositories_impl/order_repository_impl.dart';

KitchenProvider createKitchenProvider() {
  // Instanciamos el data source remoto
  final remoteDataSource = OrderRemoteDataSourceImpl();
  // Instanciamos el repositorio base
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
  // Instanciamos el adaptador de órdenes para la cocina
  final kitchenOrderAdapter = KitchenOrderAdapterImpl(
    orderRepository: orderRepository,
  );

  return KitchenProvider(
    getKitchenOrdersUseCase: GetKitchenOrdersUseCase(
      kitchenOrderPort: kitchenOrderAdapter,
    ),
    updateToPreparationUseCase: UpdateToPreparationUseCase(
      kitchenOrderPort: kitchenOrderAdapter,
    ),
    markOrderReadyUseCase: MarkOrderReadyUseCase(
      kitchenOrderPort: kitchenOrderAdapter,
    ),
  );
}
