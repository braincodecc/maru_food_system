import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository _productRepository;

  DeleteProductUseCase({required ProductRepository productRepository})
    : _productRepository = productRepository;

  Future<void> call(String productId) async {
    await _productRepository.deleteProduct(productId);
  }
}
