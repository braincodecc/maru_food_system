import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';

abstract class ClientProductPort {
  Future<List<ProductEntity>> getActiveProducts();
}