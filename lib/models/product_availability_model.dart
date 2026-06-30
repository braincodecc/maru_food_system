import 'package:maru_food_system/models/product.dart';

class ProductAvailabilityModel {
  final Product product;
  final int availableUnits;

  ProductAvailabilityModel({
    required this.product,
    required this.availableUnits,
  });

  bool get isAvailable => availableUnits > 0;
}
