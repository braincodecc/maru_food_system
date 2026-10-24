import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetActiveProductsUseCase {
  final ProductRepository _repository;

  GetActiveProductsUseCase(this._repository);

 Future<List<ProductEntity>> call(String productId) async {
    return await _repository.getActiveProducts();
  }
}