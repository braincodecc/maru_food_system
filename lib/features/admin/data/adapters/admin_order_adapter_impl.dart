import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/usecases/update_order_status_usecase.dart';

import '../../domain/ports/admin_order_port.dart';
import 'package:maru_food_system/features/order/domain/usecases/get_admin_orders_usecase.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

class AdminOrderAdapterImpl implements AdminOrderPort {
  final GetAdminOrdersUseCase _getAdminOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  AdminOrderAdapterImpl({
    required GetAdminOrdersUseCase getAdminOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _getAdminOrdersUseCase = getAdminOrdersUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase;

  @override
  Future<List<OrderEntity>> getOrders() async {
    return await _getAdminOrdersUseCase();
  }

  @override
  Future<void> changeStatus(String orderId, OrderStatus newStatus) async {
    return await _updateOrderStatusUseCase(orderId, newStatus);
  }
}
