import '../data/datasources/order_remote_datasource.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../data/adapters/order_finance_adapter_impl.dart'; // Importas tu adaptador de puerto

import '../domain/usecases/create_order_reservation_usecase.dart';
import '../domain/usecases/submit_payment_reference_usecase.dart';
import '../domain/usecases/get_orders_usecase.dart';
import '../domain/usecases/update_order_status_usecase.dart';
import '../presentation/providers/order_provider.dart';

// Importaciones necesarias del módulo de finanzas para armar el sub-árbol
import 'package:maru_food_system/features/finance/data/datasources/finance_remote_datasource.dart';
import 'package:maru_food_system/features/finance/data/repositories_impl/finance_repository_impl.dart';
import 'package:maru_food_system/features/finance/domain/usecases/distribute_order_revenue_usecase.dart';

OrderProvider createOrderProvider() {
  // 1. Data Source y Repositorio de Órdenes
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(remoteDataSource: orderRemoteDataSource);

  // 2. Data Source, Repositorio y Caso de Uso del módulo de Finanzas
  final financeRemoteDataSource = FinanceRemoteDataSourceImpl(); // O como instancies tu fuente de finanzas
  final financeRepository = FinanceRepositoryImpl(remoteDataSource: financeRemoteDataSource);
  final distributeRevenueUseCase = DistributeOrderRevenueUseCase(financeRepository);

  // 3. Adaptador que implementa el puerto (OrderFinanceService)
  final orderFinanceService = OrderFinanceAdapterImpl(distributeRevenueUseCase);

  // 4. Casos de Uso del módulo de Órdenes
  final createOrderReservationUsecase = CreateOrderReservationUsecase(orderRepository);
  final submitPaymentReferenceUsecase = SubmitPaymentReferenceUsecase(orderRepository);
  final getOrdersUseCase = GetOrdersUseCase(orderRepository);
  
  // Inyectamos el puerto abstracto (OrderFinanceService) en el caso de uso de actualización
  final updateOrderStatusUseCase = UpdateOrderStatusUseCase(
    orderRepository,
    orderFinanceService, 
  );

  // 5. Provider de Presentación
  return OrderProvider(
    createOrderReservationUsecase: createOrderReservationUsecase,
    submitPaymentReferenceUsecase: submitPaymentReferenceUsecase,
    getOrdersUseCase: getOrdersUseCase,
    updateOrderStatusUseCase: updateOrderStatusUseCase,
  );
}