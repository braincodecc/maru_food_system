import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fastfood),
        title: Text(product['name']),
        subtitle: Text('Precio: \$${product['price']}'),
        onTap: onTap,
      ),
    );
  }
}
