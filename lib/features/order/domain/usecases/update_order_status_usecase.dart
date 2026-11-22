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
    final currentOrder = await _orderRepository.getOrderById(orderId);
    if (currentOrder == null) {
      throw Exception('No se encontró la orden con ID: $orderId.');
    }

    final alreadyCompleted = currentOrder.status == OrderStatus.completed;

    // 1. Actualizamos el estado de la orden en el repositorio
    await _orderRepository.updateOrderStatus(orderId, newStatus);

    // 2. Si pasa a completado por primera vez, distribuimos ingresos en finanzas
    if (newStatus == OrderStatus.completed && !alreadyCompleted) {
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
