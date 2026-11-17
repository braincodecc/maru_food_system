// Importaciones del módulo local de órdenes
import '../data/datasources/order_remote_datasource.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../data/adapters/order_finance_adapter_impl.dart';

// Casos de uso locales (solo los usa el módulo de órdenes)
import '../domain/usecases/create_order_reservation_usecase.dart';
import '../domain/usecases/confirm_order_checkout_usecase.dart';
import '../domain/usecases/get_orders_usecase.dart';

// Caso de uso compartido (lo usan otros módulos como Delivery)
import '../domain/usecases/update_order_status_usecase.dart';
import '../domain/usecases/get_kitchen_orders_usecase.dart';
import '../domain/usecases/get_delivery_orders_usecase.dart';
import '../domain/usecases/update_order_operational_status_usecase.dart';

// Provider local de órdenes
import '../presentation/providers/order_provider.dart';

// Importamos las fábricas públicas del módulo de finanzas
import 'package:maru_food_system/features/finance/di/finance_injector.dart';

/// 1. Fábrica para el Provider local de Órdenes
OrderProvider createOrderProvider() {
  // Bases de datos y repositorios base del módulo
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: orderRemoteDataSource,
  );

  // Instanciamos directamente los casos de uso locales que NADIE MÁS fuera de order usa
  final createOrderReservationUsecase = CreateOrderReservationUsecase(
    orderRepository,
  );
  final confirmOrderCheckoutUseCase = ConfirmOrderCheckoutUseCase(
    orderRepository,
  );
  final getOrdersUseCase = GetOrdersUseCase(orderRepository);

  // Para el caso de uso que compartimos, reutilizamos la misma función fábrica pública
  final updateOrderStatusUseCase = createUpdateOrderStatusUseCase();

  return OrderProvider(
    createOrderReservationUsecase: createOrderReservationUsecase,
    confirmOrderCheckoutUseCase: confirmOrderCheckoutUseCase,
    getOrdersUseCase: getOrdersUseCase,
    updateOrderStatusUseCase:
        updateOrderStatusUseCase, // 💡 Inyectado limpiamente aquí también
  );
}

/// 2. Fábrica pública y compartida (Expuesta para que Delivery, Kitchen o Admin la usen)
UpdateOrderStatusUseCase createUpdateOrderStatusUseCase() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: orderRemoteDataSource,
  );

  // 💡 Inyectamos el caso de uso de Finanzas en el caso de uso de Órdenes
  final distributeOrderRevenueUseCase = createDistributeOrderRevenueUseCase();
  final orderFinanceAdapter = OrderFinanceAdapterImpl(
    distributeOrderRevenueUseCase: distributeOrderRevenueUseCase,
  );

  return UpdateOrderStatusUseCase(
    orderRepository: orderRepository,
    orderFinancePort: orderFinanceAdapter,
  );
}

/// 3. 💡 Fábrica pública para que el módulo Kitchen obtenga las órdenes de cocina
GetKitchenOrdersUseCase createGetKitchenOrdersUseCase() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: orderRemoteDataSource,
  );

  return GetKitchenOrdersUseCase(orderRepository: orderRepository);
}

/// 4. 💡 Fábrica pública para que el módulo delivery obtenga las órdenes del repartidor
GetDeliveryOrdersUseCase createGetDeliveryOrdersUseCase() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: orderRemoteDataSource,
  );

  return GetDeliveryOrdersUseCase(orderRepository: orderRepository);
}

/// 5. 💡 Fábrica pública para que el módulo Kitchen actualice estados operativos (Sin Finanzas)
UpdateOrderOperationalStatusUseCase
createUpdateOrderOperationalStatusUseCase() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: orderRemoteDataSource,
  );

  return UpdateOrderOperationalStatusUseCase(orderRepository: orderRepository);
}
