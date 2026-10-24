import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class ValidateCartStockUseCase {
  final ProductRepository _repository;

  ValidateCartStockUseCase(this._repository);

  /// Recibe un mapa con el ID del producto y la cantidad solicitada en el carrito (Map<productId, quantity>)
  /// Retorna una lista de productos que presentan problemas de stock. Si está vacía, todo está OK.
  Future<List<ProductEntity>> call(Map<String, int> cartItems) async {
    if (cartItems.isEmpty) return [];
    return await _repository.validateStockForCheckout(cartItems);
  }
}