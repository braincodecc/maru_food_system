import 'package:maru_food_system/features/order/domain/usecases/submit_payment_reference_usecase.dart';

import '../data/datasources/order_remote_datasource.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../domain/usecases/create_order_reservation_usecase.dart';
import '../domain/usecases/get_orders_usecase.dart';
import '../domain/usecases/update_order_status_usecase.dart';
import '../presentation/providers/order_provider.dart';

OrderProvider createOrderProvider() {
  final remoteDataSource = OrderRemoteDataSourceImpl();
  final repository = OrderRepositoryImpl(remoteDataSource: remoteDataSource);

  return OrderProvider(
    createOrderReservationUsecase: CreateOrderReservationUsecase(repository),
    submitPaymentReferenceUsecase: SubmitPaymentReferenceUsecase(repository),
    getOrdersUseCase: GetOrdersUseCase(repository),
    updateOrderStatusUseCase: UpdateOrderStatusUseCase(repository),
  );
}