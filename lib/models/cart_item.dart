import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.priceUsd * quantity;
  /*double get totalCost => product.costUsd * quantity;*/
  double get totalProfit => product.profitUsd * quantity;
}