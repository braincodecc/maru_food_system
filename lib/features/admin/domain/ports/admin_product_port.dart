import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';

abstract class AdminProductPort {
  Future<List<ProductEntity>> getProducts();
  Future<void> saveProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);
}