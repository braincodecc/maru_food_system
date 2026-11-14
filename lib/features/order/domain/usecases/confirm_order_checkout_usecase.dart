
import '../repositories/order_repository.dart';

class ConfirmOrderCheckoutUseCase {
  final OrderRepository _repository;

  ConfirmOrderCheckoutUseCase(this._repository);

  Future<void> call({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
    required bool isDelivery,
  }) async {
    // Ejecuta la confirmación completa de la orden en una sola transacción limpia
    await _repository.confirmCheckout(
      orderId: orderId,
      paymentReference: paymentReference,
      clientPhone: clientPhone,
      isDelivery: isDelivery,
    );
  }
}