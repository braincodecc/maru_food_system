import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/usecases/create_order_reservation_usecase.dart';
import 'package:maru_food_system/features/order/domain/usecases/confirm_order_checkout_usecase.dart';
import 'package:maru_food_system/features/order/domain/usecases/get_admin_orders_usecase.dart';
import 'package:maru_food_system/features/order/domain/usecases/update_order_status_usecase.dart';

import '../../domain/ports/admin_order_port.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';

class AdminOrderAdapterImpl implements AdminOrderPort {
  final GetAdminOrdersUseCase _getAdminOrdersUseCase;
  final CreateOrderReservationUsecase _createOrderReservationUsecase;
  final ConfirmOrderCheckoutUseCase _confirmOrderCheckoutUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  AdminOrderAdapterImpl({
    required GetAdminOrdersUseCase getAdminOrdersUseCase,
    required CreateOrderReservationUsecase createOrderReservationUsecase,
    required ConfirmOrderCheckoutUseCase confirmOrderCheckoutUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _getAdminOrdersUseCase = getAdminOrdersUseCase,
       _createOrderReservationUsecase = createOrderReservationUsecase,
       _confirmOrderCheckoutUseCase = confirmOrderCheckoutUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase;

  @override
  Future<List<OrderEntity>> getOrders() async {
    return await _getAdminOrdersUseCase();
  }

  @override
  Future<String?> reserveOrder({
    required String clientId,
    required bool isDelivery,
    required double totalAmount,
    required List<OrderItemEntity> items,
  }) async {
    final newOrder = OrderEntity(
      id: '',
      clientId: clientId,
      items: items,
      totalAmount: totalAmount,
      status: OrderStatus.awaitingPayment,
      paymentReference: '',
      clientPhone: '',
      isDelivery: isDelivery,
      createdAt: DateTime.now(),
    );

    return await _createOrderReservationUsecase(newOrder);
  }

  @override
  Future<void> confirmPurchase({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
    required bool isDelivery,
  }) async {
    await _confirmOrderCheckoutUseCase(
      orderId: orderId,
      paymentReference: paymentReference,
      clientPhone: clientPhone,
      isDelivery: isDelivery,
    );
  }

  @override
  Future<void> changeStatus(String orderId, OrderStatus newStatus) async {
    return await _updateOrderStatusUseCase(orderId, newStatus);
  }
}
