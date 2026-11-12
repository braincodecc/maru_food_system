import '../../domain/services/order_finance_service.dart';
import '../../domain/entities/order_entity.dart';
import 'package:maru_food_system/features/finance/domain/usecases/distribute_order_revenue_usecase.dart';

class OrderFinanceAdapterImpl implements OrderFinanceService {
  final DistributeOrderRevenueUseCase _distributeRevenueUseCase;

  OrderFinanceAdapterImpl(this._distributeRevenueUseCase);

  @override
  Future<void> distributeRevenue(OrderEntity completedOrder) async {
    // Traduce o delega la llamada al caso de uso del módulo de finanzas
    await _distributeRevenueUseCase(completedOrder);
  }
}