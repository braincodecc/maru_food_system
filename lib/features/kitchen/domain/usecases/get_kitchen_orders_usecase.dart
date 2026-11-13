import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/repositories/order_repository.dart';

class GetKitchenOrdersUseCase {
  final OrderRepository _orderRepository;

  GetKitchenOrdersUseCase(this._orderRepository);

  Future<List<OrderEntity>> call() async {
    // Obtenemos todas las órdenes del sistema (o un filtro optimizado en repositorio)
    final allOrders = await _orderRepository.getAllOrders();

    // Filtramos las que competen a cocina: approved, inPreparation y ready
    return allOrders.where((order) {
      return order.status == OrderStatus.approved ||
             order.status == OrderStatus.inPreparation ||
             order.status == OrderStatus.ready;
    }).toList();
  }
}