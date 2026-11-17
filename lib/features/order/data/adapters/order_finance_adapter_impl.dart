// Importaciones del modulo de orden
import '../../domain/entities/order_entity.dart';
import '../../domain/ports/order_finance_port.dart';

// Importaciones del modulo de finanzas
import 'package:maru_food_system/features/finance/domain/usecases/distribute_order_revenue_usecase.dart';

class OrderFinanceAdapterImpl implements OrderFinancePort {
  final DistributeOrderRevenueUseCase _distributeOrderRevenueUseCase;

  OrderFinanceAdapterImpl({
    required DistributeOrderRevenueUseCase distributeOrderRevenueUseCase,
  }) : _distributeOrderRevenueUseCase = distributeOrderRevenueUseCase;

  @override
  Future<void> distributeOrderRevenue(OrderEntity completedOrder) async {
    await _distributeOrderRevenueUseCase(completedOrder);
  }
}
