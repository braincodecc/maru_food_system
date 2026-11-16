// Importaciones del modulo de orden
import '../data/datasources/order_remote_datasource.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../data/adapters/order_finance_adapter_impl.dart';
import '../domain/usecases/create_order_reservation_usecase.dart';
import '../domain/usecases/confirm_order_checkout_usecase.dart';
import '../domain/usecases/get_orders_usecase.dart';
import '../domain/usecases/update_order_status_usecase.dart';
import '../presentation/providers/order_provider.dart';

// Importaciones del módulo de finanzas
import 'package:maru_food_system/features/finance/data/datasources/finance_remote_datasource.dart';
import 'package:maru_food_system/features/finance/data/repositories_impl/finance_repository_impl.dart';


/// 1. Fábrica para crear el OrderProvider local
OrderProvider createOrderProvider() {
  // 1. Data Source y Repositorio de Órdenes
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(
    remoteDataSource: orderRemoteDataSource,
  );

  // 2. Data Source, Repositorio de Finanzas
  final financeRemoteDataSource =
      FinanceRemoteDataSourceImpl(); // O como instancies tu fuente de finanzas
  final financeRepository = FinanceRepositoryImpl(
    remoteDataSource: financeRemoteDataSource,
  );

  // 3. Adaptador que implementa el puerto financiero para el módulo de órdenes
  final orderFinanceAdapter = OrderFinanceAdapterImpl(
    financeRepository: financeRepository,
  );

  // 4. Casos de Uso del módulo de Órdenes
  final createOrderReservationUsecase = CreateOrderReservationUsecase(
    orderRepository,
  );
  final confirmOrderCheckoutUseCase = ConfirmOrderCheckoutUseCase(
    orderRepository,
  );
  final getOrdersUseCase = GetOrdersUseCase(orderRepository);

  // Caso de Uso para actualizar el estado de la orden y distribuir ingresos
  final updateOrderStatusUseCase = UpdateOrderStatusUseCase(
    orderRepository: orderRepository,
    orderFinancePort: orderFinanceAdapter,
  );

  // 5. Provider de Presentación
  return OrderProvider(
    createOrderReservationUsecase: createOrderReservationUsecase,
    confirmOrderCheckoutUseCase: confirmOrderCheckoutUseCase,
    getOrdersUseCase: getOrdersUseCase,
    updateOrderStatusUseCase: updateOrderStatusUseCase,
  );
}

/// 2. Fábrica pura para entregar el caso de uso a otros módulos (como Delivery o Kitchen)
UpdateOrderStatusUseCase createUpdateOrderStatusUseCase() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(remoteDataSource: orderRemoteDataSource);

  // El módulo Order conecta su fin de ciclo con Finanzas de forma interna
  final financeRemoteDataSource = FinanceRemoteDataSourceImpl();
  final financeRepository = FinanceRepositoryImpl(remoteDataSource: financeRemoteDataSource);
  final orderFinanceAdapter = OrderFinanceAdapterImpl(financeRepository: financeRepository);

  return UpdateOrderStatusUseCase(
    orderRepository: orderRepository,
    orderFinancePort: orderFinanceAdapter,
  );
}
