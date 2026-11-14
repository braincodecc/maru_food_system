import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.enum.dart';
import '../../domain/usecases/create_order_reservation_usecase.dart';
import '../../domain/usecases/confirm_order_checkout_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

class OrderProvider extends ChangeNotifier {
  final CreateOrderReservationUsecase _createOrderReservationUsecase;
  final ConfirmOrderCheckoutUseCase _confirmOrderCheckoutUseCase;
  final GetOrdersUseCase _getOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  OrderProvider({
    required CreateOrderReservationUsecase createOrderReservationUsecase,
    required ConfirmOrderCheckoutUseCase confirmOrderCheckoutUseCase,
    required GetOrdersUseCase getOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _createOrderReservationUsecase = createOrderReservationUsecase,
       _confirmOrderCheckoutUseCase = confirmOrderCheckoutUseCase,
       _getOrdersUseCase = getOrdersUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OrderEntity> _allOrders = [];
  List<OrderEntity> get allOrders => _allOrders;

  /// Reserva el stock y crea el pedido en estado awaitingPayment
  Future<String?> createOrderReservation({
    required String clientId,
    required bool isDelivery,
    required double totalAmount,
    required List<OrderItemEntity> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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

      final orderId = await _createOrderReservationUsecase(newOrder);
      return orderId;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirmar orden de compra y actualizar el estado a "pendingVerification"
  Future<bool> confirmOrderPurchase({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
    required bool isDelivery,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _confirmOrderCheckoutUseCase(
        orderId: orderId,
        paymentReference: paymentReference,
        clientPhone: clientPhone,
        isDelivery: isDelivery,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar pedidos del cliente
  Future<void> loadClientOrders(String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allOrders = await _getOrdersUseCase.forClient(clientId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga todos los pedidos para la vista del administrador
  Future<void> loadAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allOrders = await _getOrdersUseCase.all();
    } catch (e) {
      _errorMessage = 'Error al cargar los pedidos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Observa el pedido activo del cliente en tiempo real
  Stream<OrderEntity?> watchActiveOrder(String clientId) {
    return _getOrdersUseCase.activeForClient(clientId);
  }

  /// Cambia el estado de un pedido (aprovado, Rechazar, etc.) y recarga la lista correspondiente
  Future<bool> changeOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    bool isAdmin = false,
    String? clientId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _updateOrderStatusUseCase(orderId, newStatus);
      // Recargamos la lista correspondiente
      if (isAdmin) {
        await loadAllOrders();
      } else if (clientId != null) {
        await loadClientOrders(clientId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
