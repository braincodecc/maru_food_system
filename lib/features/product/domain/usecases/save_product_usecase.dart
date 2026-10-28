import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SaveProductUseCase {
  final ProductRepository _repository;

  SaveProductUseCase(this._repository);

  Future<void> call(ProductEntity product) async {
    // Si el ID está vacío, es un producto nuevo; de lo contrario, se actualiza
    if (product.id.isEmpty) {
      await _repository.createProduct(product);
    } else {
      await _repository.updateProduct(product);
    }
  }
}