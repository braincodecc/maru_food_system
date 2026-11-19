// Importaciones del módulo local de órdenes
import '../data/datasources/order_remote_datasource.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../data/adapters/order_finance_adapter_impl.dart';

// Caso de uso compartido (lo usan otros módulos como Delivery)
import '../domain/usecases/update_order_status_usecase.dart';
import '../domain/usecases/update_order_operational_status_usecase.dart';
import '../domain/usecases/create_order_reservation_usecase.dart';
import '../domain/usecases/confirm_order_checkout_usecase.dart';
import '../domain/usecases/get_admin_orders_usecase.dart';
import '../domain/usecases/get_client_orders_usecase.dart';
import '../domain/usecases/get_kitchen_orders_usecase.dart';
import '../domain/usecases/get_delivery_orders_usecase.dart';


// Importamos las fábricas públicas del módulo de finanzas
import 'package:maru_food_system/features/finance/di/finance_injector.dart';
/// 
OrderRepositoryImpl _createOrderRepository() {
  final orderRemoteDataSource = OrderRemoteDataSourceImpl();
  return OrderRepositoryImpl(remoteDataSource: orderRemoteDataSource);
}

/// 2. Fábrica pública y compartida (Expuesta para que Delivery, Kitchen o Admin la usen)
UpdateOrderStatusUseCase createUpdateOrderStatusUseCase() {
  // 💡 Inyectamos el caso de uso de Finanzas en el caso de uso de Órdenes
  final distributeOrderRevenueUseCase = createDistributeOrderRevenueUseCase();
  final orderFinanceAdapter = OrderFinanceAdapterImpl(
    distributeOrderRevenueUseCase: distributeOrderRevenueUseCase,
  );

  return UpdateOrderStatusUseCase(
    orderRepository: _createOrderRepository(),
    orderFinancePort: orderFinanceAdapter,
  );
}

/// 5. 💡 Fábrica pública para que el módulo Kitchen actualice estados operativos (Sin Finanzas)
UpdateOrderOperationalStatusUseCase
createUpdateOrderOperationalStatusUseCase() {
  return UpdateOrderOperationalStatusUseCase(orderRepository: _createOrderRepository());
}

CreateOrderReservationUsecase createCreateOrderReservationUsecase() {
  return CreateOrderReservationUsecase(_createOrderRepository());
}

ConfirmOrderCheckoutUseCase createConfirmOrderCheckoutUseCase() {
  return ConfirmOrderCheckoutUseCase(_createOrderRepository());
}

GetAdminOrdersUseCase createGetAdminOrdersUseCase() {
  return GetAdminOrdersUseCase(_createOrderRepository());
}

GetClientOrdersUseCase createGetClientOrdersUseCase() {
  return GetClientOrdersUseCase(_createOrderRepository());
}

/// 4. 💡 Fábrica pública para que el módulo delivery obtenga las órdenes del repartidor
GetDeliveryOrdersUseCase createGetDeliveryOrdersUseCase() {
  return GetDeliveryOrdersUseCase(orderRepository: _createOrderRepository());
}

/// 3. 💡 Fábrica pública para que el módulo Kitchen obtenga las órdenes de cocina
GetKitchenOrdersUseCase createGetKitchenOrdersUseCase() {
  return GetKitchenOrdersUseCase(orderRepository: _createOrderRepository());
}

