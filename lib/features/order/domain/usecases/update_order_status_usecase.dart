import '../ports/order_finance_port.dart';
import '../entities/order_status.enum.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _orderRepository;
  final OrderFinancePort _orderFinancePort;

  UpdateOrderStatusUseCase({
    required OrderRepository orderRepository,
    required OrderFinancePort orderFinancePort,
  }) : _orderRepository = orderRepository,
       _orderFinancePort = orderFinancePort;

  Future<void> call(String orderId, OrderStatus newStatus) async {
    // 1. Actualizamos el estado de la orden en el repositorio (Firestore / Base de datos)
    await _orderRepository.updateOrderStatus(orderId, newStatus);

    // 2. Si la orden se marca como completada, necesitamos los datos detallados para las finanzas
    if (newStatus == OrderStatus.completed) {
      final updatedOrder = await _orderRepository.getOrderById(orderId);

      if (updatedOrder == null) {
        throw Exception(
          'No se pudo encontrar la orden con ID: $orderId para procesar su distribución financiera.',
        );
      }

      // 3. Invocamos el puerto financiero pasando la entidad completa
      await _orderFinancePort.distributeOrderRevenue(updatedOrder);
    }
  }
}
