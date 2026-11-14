import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.enum.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<String?> createOrderWithStockReservation(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    return await _remoteDataSource.createOrderWithStockReservation(model);
  }

  @override
  Future<void> confirmCheckout({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
    required bool isDelivery,
  }) async {
    await _remoteDataSource.updateOrderData(
      orderId: orderId,
      paymentReference: paymentReference,
      clientPhone: clientPhone,
      isDelivery: isDelivery,
    );
  }

  @override
  Future<List<OrderEntity>> getOrdersForClient(String clientId) async {
    final models = await _remoteDataSource.getOrdersForClient(clientId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    final models = await _remoteDataSource.getAllOrders();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    final model = await _remoteDataSource.getOrderById(orderId);
    return model?.toEntity();
  }

  @override
  Future<bool> hasActiveOrder(String clientId) async {
    return await _remoteDataSource.hasActiveOrder(clientId);
  }

  @override
  Stream<OrderEntity?> watchActiveOrder(String clientId) {
    final modelStream = _remoteDataSource.watchActiveOrder(clientId);
    return modelStream.map((model) => model?.toEntity());
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _remoteDataSource.updateOrderStatus(orderId, newStatus);
  }
}
