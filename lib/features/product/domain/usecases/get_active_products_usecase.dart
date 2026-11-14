import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetActiveProductsUseCase {
  final ProductRepository _productRepository;

  GetActiveProductsUseCase({required ProductRepository productRepository})
    : _productRepository = productRepository;

  Future<List<ProductEntity>> call() async {
    return await _productRepository.getActiveProducts();
  }
}
