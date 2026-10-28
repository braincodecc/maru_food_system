import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<void> call(String productId) async {
    await _repository.deleteProduct(productId);
  }
}