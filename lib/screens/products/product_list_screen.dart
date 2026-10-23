
import 'package:flutter/material.dart';
import '../../domain/availability/product_availability_service.dart';
import '../../models/product_availability_model.dart';
import '../../services/products_service.dart';
import '../../services/settings_service.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsService = context.read<ProductsService>();
    final settingsService = context.read<SettingsService>();
    final productAvailabilityService = context.read<ProductAvailabilityService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) {
              return Badge(
                label: Text(cart.totalItems.toString()),
                isLabelVisible: cart.totalItems > 0,
                offset: const Offset(-8, 8),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/products/new'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<double>(
        stream: settingsService.getExchangeRate(),
        builder: (context, rateSnapshot) {

          if (rateSnapshot.hasError) {
            return Center(child: Text("Error: ${rateSnapshot.error}"));
          }

          if (rateSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rate = rateSnapshot.data ?? 0.0;

          return StreamBuilder<List<ProductAvailabilityModel>>(
            stream: productAvailabilityService.watchAvailability(
              productsService.getProducts(onlyActive: false),
            ),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Aún no tienes productos registrados", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              final productsAvailability = snapshot.data ?? [];

              return ListView.builder(
                itemCount: productsAvailability.length,
                itemBuilder: (_, index) {
                  return _ProductListItem(
                    item: productsAvailability[index],
                    rate: rate,
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

class _ProductListItem extends StatelessWidget {
  final ProductAvailabilityModel item;
  final double rate;

  const _ProductListItem({required this.item, required this.rate});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final available = item.availableUnits;
    final priceBs = rate * product.priceUsd;
    final bool outOfStock = available <= 0;
    final bool lowStock = available > 0 && available <= 3;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell( // Permite un efecto visual al tocar la tarjeta
        borderRadius: BorderRadius.circular(15),
        onTap: outOfStock ? null : () => _handleAction(context, 'cart', product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono o Avatar del producto (opcional si tienes imágenes luego)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.fastfood, color: Colors.blueGrey.shade400),
                  ),
                  const SizedBox(width: 12),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        _buildStockBadge(available, outOfStock, lowStock),
                      ],
                    ),
                  ),

                  // Precios destacados
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product.priceUsd.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                        ),
                      ),
                      Text(
                        'Bs ${priceBs.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Acciones inferiores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Acciones secundarias (Menu)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) => _handleAction(context, value, product),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'recipe', child: Text('Ver Receta')),
                      const PopupMenuItem(value: 'edit', child: Text('Editar Producto')),
                    ],
                  ),

                  // Botón principal de compra
                  ElevatedButton.icon(
                    onPressed: outOfStock ? null : () => _handleAction(context, 'cart', product),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('AGREGAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para el indicador de stock
  Widget _buildStockBadge(int available, bool outOfStock, bool lowStock) {
    Color color = Colors.green;
    String text = 'Disponible: $available';
    IconData icon = Icons.check_circle_outline;

    if (outOfStock) {
      color = Colors.red;
      text = 'Agotado';
      icon = Icons.error_outline;
    } else if (lowStock) {
      color = Colors.orange;
      text = '¡Últimas $available unidades!';
      icon = Icons.warning_amber_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String value, dynamic product) {
    switch (value) {
      case 'cart':
        context.read<CartProvider>().addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} agregado'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 800),
          ),
        );
        break;
      case 'recipe':
        Navigator.pushNamed(context, '/recipe-form', arguments: product);
        break;
      case 'edit':
        Navigator.pushNamed(context, '/products/edit', arguments: product);
        break;
    }
  }
}
