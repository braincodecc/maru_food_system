import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fastfood, size: 80),
            const SizedBox(height: 20),
            Text(
              product['name'],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text('Precio: \$${product['price']}'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/products/edit',
                  arguments: product,
                );
              },
              child: const Text('Editar Producto'),
            )
          ],
        ),
      ),
    );
  }
}
