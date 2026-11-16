// Importaciones del modulo de delivery
import '../data/adapters/delivery_order_adapter_impl.dart';
import '../domain/usecases/get_delivery_orders_usecase.dart';
import '../domain/usecases/start_delivery_usecase.dart';
import '../domain/usecases/complete_delivery_usecase.dart';
import '../presentation/providers/delivery_provider.dart';

// Importaciones del módulo de órdenes y finanzas
import 'package:maru_food_system/features/order/data/datasources/order_remote_datasource.dart';
import 'package:maru_food_system/features/order/data/repositories_impl/order_repository_impl.dart';
import 'package:maru_food_system/features/order/di/order_injector.dart'; // 👈 Importas el inyector de órdenes

DeliveryProvider createDeliveryProvider() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(remoteDataSource: orderRemoteDataSource);

  // 💡 Pides el caso de uso ya armado al módulo dueño (Order)
  final updateOrderStatusUseCase = createUpdateOrderStatusUseCase();

  // Se lo pasas al adaptador de delivery
  final deliveryOrderAdapter = DeliveryOrderAdapterImpl(orderRepository: orderRepository, updateOrderStatusUseCase: updateOrderStatusUseCase);

  return DeliveryProvider(
    getDeliveryOrdersUseCase: GetDeliveryOrdersUseCase(deliveryOrderPort: deliveryOrderAdapter),
    startDeliveryUseCase: StartDeliveryUseCase(deliveryOrderPort: deliveryOrderAdapter),
    completeDeliveryUseCase: CompleteDeliveryUseCase(deliveryOrderPort: deliveryOrderAdapter),
  );
}