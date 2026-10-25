import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../product.dart';
import '../../../identity/identity.dart'; // Para poder cerrar sesión o validar rol si es necesario

class ClientMenuScreen extends StatefulWidget {
  const ClientMenuScreen({super.key});

  @override
  State<ClientMenuScreen> createState() => _ClientMenuScreenState();
}

class _ClientMenuScreenState extends State<ClientMenuScreen> {
  // Carrito temporal local: { productId: quantity }
  final Map<String, int> _cart = {};

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú - Maru Food'),
        actions: [
          // Botón para cerrar sesión (demostrando uso del módulo identity)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              // AuthWrapper se encargará de redirigir al Login automáticamente
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
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
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
                  ? const Center(
                      child: Text(
                        'No hay productos disponibles en este momento.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: productProvider.activeProducts.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.activeProducts[index];
                        // Obtenemos el stock actual directamente de la caché en memoria del Provider
                        final cachedStock = productProvider.getCachedStock(product.id);
                        final cartQuantity = _cart[product.id] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Imagen del producto (o placeholder si está vacía)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              _buildPlaceholderImage(),
                                        )
                                      : _buildPlaceholderImage(),
                                ),
                                const SizedBox(width: 16),
                                // Información del producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            '\$${product.salePrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Stock: $cachedStock',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cachedStock > 0 ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Controles de cantidad para el carrito
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: Colors.green,
                                      onPressed: cachedStock > 0
                                          ? () {
                                              setState(() {
                                                _cart[product.id] = cartQuantity + 1;
                                              });
                                              // Descontamos en la caché local del Provider
                                              productProvider.updateLocalCacheAfterAddToCart(product.id, -1);
                                            }
                                          : null, // Deshabilitado si no hay stock en caché
                                    ),
                                    Text(
                                      '$cartQuantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      color: Colors.red,
                                      onPressed: cartQuantity > 0
                                          ? () {
                                              setState(() {
                                                _cart[product.id] = cartQuantity - 1;
                                                if (_cart[product.id] == 0) {
                                                  _cart.remove(product.id);
                                                }
                                              });
                                              // Devolvemos a la caché local del Provider
                                              productProvider.updateLocalCacheAfterAddToCart(product.id, 1);
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      // Botón flotante para confirmar compra (Checkout)
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _handleCheckout(context, productProvider),
              label: Text('Confirmar Pedido (${_cart.values.reduce((a, b) => a + b)})'),
              icon: const Icon(Icons.shopping_cart_checkout),
              backgroundColor: Colors.deepOrange,
            )
          : null,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.orange[100],
      child: const Icon(Icons.fastfood, color: Colors.deepOrange, size: 40),
    );
  }

  /// Lógica para procesar la compra utilizando las validaciones del Provider
  void _handleCheckout(BuildContext context, ProductProvider productProvider) async {
    // Mostramos un indicador de carga o diálogo de proceso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Ejecutamos la validación y compra atómica en Firestore
    final success = await productProvider.checkout(_cart);

    // Cerramos el diálogo de carga
    Navigator.of(context).pop();

    if (success) {
      setState(() {
        _cart.clear(); // Limpiamos el carrito local
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido confirmado con éxito! Stock descontado.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Si hubo error de stock o validación, mostramos el mensaje del provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Error al procesar la compra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}