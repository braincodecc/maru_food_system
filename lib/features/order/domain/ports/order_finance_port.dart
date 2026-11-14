import '../entities/order_entity.dart';

abstract class OrderFinancePort {
  Future<void> distributeOrderRevenue(OrderEntity completedOrder);
}