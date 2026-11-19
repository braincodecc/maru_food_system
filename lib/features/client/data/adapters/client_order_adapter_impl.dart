import '../../domain/ports/client_order_port.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_status.enum.dart';
import 'package:maru_food_system/features/order/domain/usecases/create_order_reservation_usecase.dart';
import 'package:maru_food_system/features/order/domain/usecases/confirm_order_checkout_usecase.dart';
import 'package:maru_food_system/features/order/domain/usecases/get_client_orders_usecase.dart';

class ClientOrderAdapterImpl implements ClientOrderPort {
  final CreateOrderReservationUsecase _createOrderReservationUsecase;
  final ConfirmOrderCheckoutUseCase _confirmOrderCheckoutUseCase;
  final GetClientOrdersUseCase _getClientOrdersUseCase;

  ClientOrderAdapterImpl({
    required CreateOrderReservationUsecase createOrderReservationUsecase,
    required ConfirmOrderCheckoutUseCase confirmOrderCheckoutUseCase,
    required GetClientOrdersUseCase getClientOrdersUseCase,
  })  : _createOrderReservationUsecase = createOrderReservationUsecase,
        _confirmOrderCheckoutUseCase = confirmOrderCheckoutUseCase,
        _getClientOrdersUseCase = getClientOrdersUseCase;

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
  Stream<OrderEntity?> watchActiveOrder(String clientId) {
    return _getClientOrdersUseCase.active(clientId);
  }
}