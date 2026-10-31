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
  Future<String?> createOrderReservation(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    return await _remoteDataSource.createOrderWithStockReservation(model);
  }

  @override
  Future<void> submitPaymentReference(
    String orderId,
    String paymentReference,
    String clientPhone,
  ) async {
    await _remoteDataSource.submitPaymentReference(
      orderId,
      paymentReference,
      clientPhone,
    );
  }

  @override
  Future<List<OrderEntity>> getOrdersForClient(String clientId) async {
    return await _remoteDataSource.getOrdersForClient(clientId);
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    return await _remoteDataSource.getAllOrders();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _remoteDataSource.updateOrderStatus(orderId, newStatus);
  }
}
