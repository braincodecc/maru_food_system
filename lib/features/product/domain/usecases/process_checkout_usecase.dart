import '../repositories/product_repository.dart';

class ProcessCheckoutUseCase {
  final ProductRepository _repository;

  ProcessCheckoutUseCase(this._repository);

  /// Recibe los ítems del carrito y procesa el descuento de inventario
  Future<void> call(Map<String, int> cartItems) async {
    if (cartItems.isEmpty) {
      throw Exception('El carrito está vacío, no se puede procesar la compra.');
    }
    
    await _repository.processCheckout(cartItems);
  }
}