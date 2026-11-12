import '../entities/order_status.enum.dart';
import '../repositories/order_repository.dart';
import '../services/order_finance_service.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;
  final OrderFinanceService _financeService; // <-- Usamos el puerto abstracto

  UpdateOrderStatusUseCase(this._repository, this._financeService);

  Future<void> call(String orderId, OrderStatus newStatus) async {
    // 1. Actualizamos el estado de la orden en el repositorio (Firestore / Base de datos)
    await _repository.updateOrderStatus(orderId, newStatus);

    // 2. Si la orden se marca como completada, necesitamos los datos detallados para las finanzas
    if (newStatus == OrderStatus.delivered) {
      final updatedOrder = await _repository.getOrderById(orderId);

      if (updatedOrder == null) {
        throw Exception(
          'No se pudo encontrar la orden con ID: $orderId para procesar su distribución financiera.',
        );
      }

      // 3. Invocamos el puerto financiero pasando la entidad completa
      await _financeService.distributeRevenue(updatedOrder);
    }
  }
}
