import 'package:flutter/material.dart';
import 'package:maru_food_system/app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../product.dart';
import '../../../identity/identity.dart'; // Para el botón de cerrar sesión

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración - Maru Food'),
        actions: [
          // Botón para cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              // AuthWrapper redirigirá automáticamente al Login
                            // Limpiamos todo el historial de navegación y regresamos al AuthWrapper raíz ('/')
              Navigator.pushNamedAndRemoveUntil( // Elimina todas las pantallas superiores de la pila
                context,
                AppRoutes.initial,
                (route) => false, // Elimina todas las pantallas anteriores de la pila
              );
            },
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      productProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => productProvider.loadActiveProducts(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : productProvider.activeProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay productos registrados en el inventario.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToProductForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Primer Producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productProvider.activeProducts.length,
              itemBuilder: (context, index) {
                final product = productProvider.activeProducts[index];

                // Validamos si el producto requiere reposición según su stock mínimo
                final bool isLowStock = product.needsRestock;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isLowStock
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Venta: \$${product.salePrice.toStringAsFixed(2)} | Costo: \$${product.purchasePrice.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLowStock
                                    ? Colors.red
                                    : Colors.green[700],
                              ),
                            ),
                            if (isLowStock) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '¡Reponer stock!',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepOrange),
                      tooltip: 'Editar Producto',
                      onPressed: () =>
                          _navigateToProductForm(context, product: product),
                    ),
                  ),
                );
              },
            ),
      // Botón flotante para crear un nuevo producto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.orange[100],
      child: const Icon(Icons.fastfood, color: Colors.deepOrange, size: 30),
    );
  }

  static Future<void> _navigateToProductForm(
    BuildContext context, {
    ProductEntity? product,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(productToEdit: product),
      ),
    );
  }
}
