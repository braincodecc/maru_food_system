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

    final isAlreadyTerminal =
        currentOrder.status == OrderStatus.completed ||
        currentOrder.status == OrderStatus.rejected;

    if (isAlreadyTerminal && currentOrder.status != newStatus) {
      throw Exception(
        'No se puede modificar una orden que ya está en estado ${currentOrder.status.label}.',
      );
    }

    if (currentOrder.status == newStatus) {
      return;
    }

    // 1. Actualizamos el estado de la orden en el repositorio
    await _orderRepository.updateOrderStatus(orderId, newStatus);

    // 2. Si pasa a completado, distribuimos ingresos en finanzas
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
