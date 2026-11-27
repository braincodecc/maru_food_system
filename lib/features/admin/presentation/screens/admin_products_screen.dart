import 'package:flutter/material.dart';
import 'package:maru_food_system/app/routes/app_routes.dart';
import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';
import 'package:provider/provider.dart';
import '../../../identity/identity.dart';
import '../providers/admin_product_provider.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración - Maru Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              // AuthWrapper redirigirá automáticamente al Login
              // Limpiamos todo el historial de navegación y regresamos al AuthWrapper raíz ('/')
              Navigator.pushNamedAndRemoveUntil(
                // Elimina todas las pantallas superiores de la pila
                context,
                AppRoutes.initial,
                (route) =>
                    false, // Elimina todas las pantallas anteriores de la pila
              );
            },
          ),
        ],
      ),
      body: AdminProductsBody(),
    );
  }
}

class AdminProductsBody extends StatefulWidget {
  const AdminProductsBody({super.key});

  @override
  State<AdminProductsBody> createState() => _AdminProductsBodyState();
}

class _AdminProductsBodyState extends State<AdminProductsBody> {
  @override
  void initState() {
    super.initState();
    // Se ejecuta automáticamente al abrir la pantalla para garantizar datos frescos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProductProvider = context.watch<AdminProductProvider>();
    Widget content;

    adminProductProvider.isLoading
        ? content = const Center(child: CircularProgressIndicator())
        : adminProductProvider.errorMessage != null
        ? content = Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    adminProductProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProductProvider.loadProducts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        : adminProductProvider.products.isEmpty
        ? content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
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
        : content = ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminProductProvider.products.length,
            itemBuilder: (context, index) {
              final product = adminProductProvider.products[index];

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
          );

    return Stack(
      children: [
        content,
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToProductForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Producto'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
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

  Future<void> _navigateToProductForm(
    BuildContext context, {
    ProductEntity? product,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(productToEdit: product),
      ),
    );
    if (!mounted) return;
    await context.read<AdminProductProvider>().loadProducts();
  }
}