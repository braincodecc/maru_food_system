import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gestores/carrito_provider.dart';

class DetallePedidoModal extends StatelessWidget {
  const DetallePedidoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    // 1. Detecta si el teclado en pantalla está abierto
    final double tecladoPadding = MediaQuery.of(context).viewInsets.bottom;

    // 2. Detecta la altura exacta de la barra de navegación de Android (gestos o botones)
    final double barraAndroidPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Evita que el teclado numérico tape los totales en pantallas pequeñas
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        // 3. SOLUCIÓN: Si el teclado está abierto, usa el espacio del teclado.
        // Si está cerrado, usa el de la barra de Android. Agregamos un pequeño margen (+ 16) por estética.
        bottom: tecladoPadding > 0
            ? tecladoPadding + 16
            : barraAndroidPadding + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tirador visual superior para denotar que es deslizable
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🛒 Resumen de la Orden',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (carrito.items.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    carrito.limpiarCarrito();
                    Navigator.pop(
                      context,
                    ); // Cierra la pantalla modal si se vacía todo
                  },
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label: const Text(
                    'Vaciar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Contenedor scrolleable interno para la auditoría de productos
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height *
                  0.45, // 45% de la pantalla como máximo
            ),
            child: carrito.items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No hay productos en el carrito.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: carrito.items.length,
                    itemBuilder: (context, index) {
                      final item = carrito.items[index];
                      final double totalBsItem =
                          item.totalUsd * carrito.tasaCambio;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${item.quantity} x \$${item.priceUsd.toStringAsFixed(2)} = \$${item.totalUsd.toStringAsFixed(2)}\n(${totalBsItem.toStringAsFixed(2)} Bs.)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                item.quantity == 1
                                    ? Icons.delete_outline
                                    : Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (item.quantity == 1) {
                                  carrito.removerProducto(item.productId);
                                  if (carrito.items.isEmpty)
                                    Navigator.pop(context);
                                } else {
                                  carrito.disminuirCantidad(item.productId);
                                }
                              },
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                              ),
                              onPressed: () =>
                                  carrito.incrementarCantidad(item.productId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Bloque de liquidación monetaria en caliente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total General:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${carrito.totalUsd.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${carrito.totalBs.toStringAsFixed(2)} Bs.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Acción de salida
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Entendido, Continuar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
