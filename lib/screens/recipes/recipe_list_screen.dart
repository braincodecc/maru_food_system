import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante para context.read
import '../../models/product.dart';
import '../../services/products_service.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsService = context.read<ProductsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas de Productos'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productsService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar productos'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('No hay productos registrados'));
          }

          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final product = products[index];

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.restaurant_menu),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Precio de venta: \$${product.priceUsd.toStringAsFixed(2)}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/recipe-form',
                    arguments: product,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}