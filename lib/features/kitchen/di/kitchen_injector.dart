import 'package:maru_food_system/features/order/data/datasources/order_remote_datasource.dart';
import 'package:maru_food_system/features/order/data/repositories_impl/order_repository_impl.dart';
import '../domain/usecases/get_kitchen_orders_usecase.dart';
import '../domain/usecases/update_to_preparation_usecase.dart';
import '../domain/usecases/mark_order_ready_usecase.dart';
import '../presentation/providers/kitchen_provider.dart';

KitchenProvider createKitchenProvider() {
  final remoteDataSource = OrderRemoteDataSourceImpl();
  final orderRepository = OrderRepositoryImpl(remoteDataSource: remoteDataSource);

  return KitchenProvider(
    getKitchenOrdersUseCase: GetKitchenOrdersUseCase(orderRepository),
    updateToPreparationUseCase: UpdateToPreparationUseCase(orderRepository),
    markOrderReadyUseCase: MarkOrderReadyUseCase(orderRepository),
  );
}