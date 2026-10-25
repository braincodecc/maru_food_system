import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetActiveProductsUseCase {
  final ProductRepository _repository;

  GetActiveProductsUseCase(this._repository);

 Future<List<ProductEntity>> call() async {
    return await _repository.getActiveProducts();
  }
}