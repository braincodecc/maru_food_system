import '../repositories/order_repository.dart';

class SubmitPaymentReferenceUsecase {
  final OrderRepository _repository;
  SubmitPaymentReferenceUsecase(this._repository);

  Future<void> call({
    required String orderId,
    required String paymentReference,
    required String clientPhone,
  }) async {
    return await _repository.submitOrderPaymentReference(
      orderId,
      paymentReference,
      clientPhone,
    );
  }
}
