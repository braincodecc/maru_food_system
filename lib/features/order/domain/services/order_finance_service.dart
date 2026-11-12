import '../entities/order_entity.dart';

abstract class OrderFinanceService {
  Future<void> distributeRevenue(OrderEntity completedOrder);
}