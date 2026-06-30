import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../services/settings_service.dart';

class SaleCartScreen extends StatelessWidget {
  const SaleCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final settingsService = context.read<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClearCart(context, cart),
              tooltip: "Vaciar carrito",
            )
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final CartItem item = cart.items[index];

                // Usamos Dismissible para borrar deslizando
                return Dismissible(
                  key: Key(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => cart.removeProduct(item.product),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'USD ${item.product.priceUsd.toStringAsFixed(2)} x ${item.quantity}',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text('${item.quantity}'),
                      ),
                      trailing: _buildQuantityActions(cart, item),
                    ),
                  ),
                );
              },
            ),
          ),
          CartTotalSection(
            cart: cart,
            settings: settingsService,
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('El carrito está vacío', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuantityActions(CartProvider cart, CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => cart.decreaseProduct(item.product),
        ),
        Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: () => cart.addProduct(item.product),
        ),
      ],
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Vaciar carrito?"),
        content: const Text("Se eliminarán todos los productos seleccionados."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(ctx);
            },
            child: const Text("VACIAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CartTotalSection extends StatelessWidget {
  final CartProvider cart;
  final SettingsService settings;

  const CartTotalSection({
    super.key,
    required this.cart,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // Al ser un widget, el 'context' ya está disponible automáticamente en el build
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<double>(
                  stream: settings.getExchangeRate(),
                  builder: (context, snapshot) {
                    final rate = snapshot.data ?? 0.0;
                    final totalUsd = cart.totalPrice;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'USD ${totalUsd.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (rate > 0)
                          Text(
                            'BS ${(totalUsd * rate).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: cart.items.isEmpty
                    ? null
                    : () => Navigator.pushNamed(context, '/checkout'),
                child: const Text('FINALIZAR COMPRA', style: TextStyle(letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}