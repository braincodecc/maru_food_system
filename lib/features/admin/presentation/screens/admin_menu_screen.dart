import 'package:flutter/material.dart';
import 'package:maru_food_system/app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'admin_checkout_screen.dart';

// Importamos el proveedor de ordenes
import '../providers/admin_product_provider.dart';
import '../providers/admin_order_provider.dart';

// Importamos del modulo de ordenes sus entidades y enumerables
import 'package:maru_food_system/features/order/domain/entities/order_item_entity.dart';

// Importaciones del modulo de identidad
import '../../../identity/identity.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú - Maru Food'),
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
      body: AdminMenuBody(),
    );
  }
}

/*
class _AdminMenuScreenState extends State<AdminMenuScreen> {
  // Carrito temporal local: { productId: quantity }
  final Map<String, int> _cart = {};

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
    final productProvider = context.watch<AdminProductProvider>();
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
                      onPressed: () => productProvider.loadProducts(),
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
                                      color: cachedStock > 0
                                          ? Colors.green
                                          : Colors.red,
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
                                      productProvider
                                          .updateLocalCacheAfterAddToCart(
                                            product.id,
                                            -1,
                                          );
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
                                      productProvider
                                          .updateLocalCacheAfterAddToCart(
                                            product.id,
                                            1,
                                          );
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
      // Botón flotante para ir al Checkout de Pago Móvil
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _handleReserveAndCheckout(context, productProvider),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Proceder al Pago (${_cart.values.reduce((a, b) => a + b)})',
              ),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
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

  /// Reservar el stock y navegar a la pantalla de pago si la reserva es exitosa.
  void _handleReserveAndCheckout(
    BuildContext context,
    AdminProductProvider productProvider,
  ) async {
    final identityProvider = context.read<IdentityProvider>();
    final orderProvider = context.read<AdminOrderProvider>();
    final clientId = identityProvider.currentUser?.id;

    if (clientId == null) return;

    // 1. Mostrar diálogo de carga de reserva
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Reservando stock en almacén...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    // 2. Transformar el Map del carrito en una List<OrderItemEntity> (congelando el Snapshot)
    final List<OrderItemEntity> orderItems = [];
    double totalAmount = 0.0;

    _cart.forEach((productId, quantity) {
      final product = productProvider.activeProducts.firstWhere(
        (p) => p.id == productId,
      );

      totalAmount += product.salePrice * quantity;

      orderItems.add(
        OrderItemEntity(
          productId: product.id,
          productName: product.name, // Snapshot del nombre
          unitPrice: product.salePrice, // Snapshot del precio de venta
          unitCost: product.purchasePrice, // Snapshot del costo de producción
          quantity: quantity, // Cantidad comprada
        ),
      );
    });

    /// 3. Ejecutar reserva atómica en Firestore pasando la lista de entidades
    final orderId = await orderProvider.createOrderReservation(
      clientId: clientId,
      isDelivery: false,
      totalAmount: totalAmount,
      items: orderItems,
    );

    // Ocultar diálogo de carga
    Navigator.of(context).pop();

    if (orderId != null) {
      // 4. Si la reserva fue exitosa, limpiamos el carrito local y navegamos al Checkout con el ID y detalle
      setState(() => _cart.clear());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminCheckoutScreen(
            orderId: orderId,
            items: orderItems,
            totalAmount: totalAmount,
            //availableProducts: productProvider.activeProducts,
          ),
        ),
      );
    } else {
      // Si falló por falta de stock, mostramos el error exacto antes de que el cliente pague
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProvider.errorMessage ?? 'No hay suficiente stock disponible.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
*/
class AdminMenuBody extends StatefulWidget {
  const AdminMenuBody({super.key});

  @override
  State<AdminMenuBody> createState() => _AdminMenuBodyState();
}

class _AdminMenuBodyState extends State<AdminMenuBody> {
  // Carrito temporal local: { productId: quantity }
  final Map<String, int> _cart = {};

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
    final productProvider = context.watch<AdminProductProvider>();
    Widget content;

    productProvider.isLoading
        ? content = const Center(child: CircularProgressIndicator())
        : productProvider.errorMessage != null
        ? content = Center(
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
                    onPressed: () => productProvider.loadProducts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        : productProvider.activeProducts.isEmpty
        ? content = const Center(
            child: Text(
              'No hay productos disponibles en este momento.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : content = ListView.builder(
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
                                    color: cachedStock > 0
                                        ? Colors.green
                                        : Colors.red,
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
                                    productProvider
                                        .updateLocalCacheAfterAddToCart(
                                          product.id,
                                          -1,
                                        );
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
                                    productProvider
                                        .updateLocalCacheAfterAddToCart(
                                          product.id,
                                          1,
                                        );
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
          );

    return Stack(
      children: [
        content,
        Positioned(
          right: 16,
          bottom: 16,
          child: _cart.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      _handleReserveAndCheckout(context, productProvider),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text(
                    'Proceder al Pago (${_cart.values.reduce((a, b) => a + b)})',
                  ),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                )
              : const SizedBox.shrink(),
        ),
      ],
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

  /// Reservar el stock y navegar a la pantalla de pago si la reserva es exitosa.
  void _handleReserveAndCheckout(
    BuildContext context,
    AdminProductProvider productProvider,
  ) async {
    final identityProvider = context.read<IdentityProvider>();
    final orderProvider = context.read<AdminOrderProvider>();
    final clientId = identityProvider.currentUser?.id;

    if (clientId == null) return;

    // 1. Mostrar diálogo de carga de reserva
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Reservando stock en almacén...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    // 2. Transformar el Map del carrito en una List<OrderItemEntity> (congelando el Snapshot)
    final List<OrderItemEntity> orderItems = [];
    double totalAmount = 0.0;

    _cart.forEach((productId, quantity) {
      final product = productProvider.activeProducts.firstWhere(
        (p) => p.id == productId,
      );

      totalAmount += product.salePrice * quantity;

      orderItems.add(
        OrderItemEntity(
          productId: product.id,
          productName: product.name, // Snapshot del nombre
          unitPrice: product.salePrice, // Snapshot del precio de venta
          unitCost: product.purchasePrice, // Snapshot del costo de producción
          quantity: quantity, // Cantidad comprada
        ),
      );
    });

    /// 3. Ejecutar reserva atómica en Firestore pasando la lista de entidades
    final orderId = await orderProvider.createOrderReservation(
      clientId: clientId,
      isDelivery: false,
      totalAmount: totalAmount,
      items: orderItems,
    );

    // Ocultar diálogo de carga
    Navigator.of(context).pop();

    if (orderId != null) {
      // 4. Si la reserva fue exitosa, limpiamos el carrito local y navegamos al Checkout con el ID y detalle
      setState(() => _cart.clear());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminCheckoutScreen(
            orderId: orderId,
            items: orderItems,
            totalAmount: totalAmount,
            //availableProducts: productProvider.activeProducts,
          ),
        ),
      );
    } else {
      // Si falló por falta de stock, mostramos el error exacto antes de que el cliente pague
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProvider.errorMessage ?? 'No hay suficiente stock disponible.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
