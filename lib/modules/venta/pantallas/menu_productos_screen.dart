import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gestores/carrito_provider.dart';
import '../datos/articulo_pedido_model.dart';
import 'componentes/header_ver_pedido.dart';
import '/../models/product.dart'; // Tu modelo de productos
// Al crear el modulo de productos esta importacion cambiara a la ruta correcta de tu servicio de productos
import '/../services/products_service.dart'; // Tu servicio de productos

class MenuProductosScreen extends StatefulWidget {
  final VoidCallback onSiguiente;
  final VoidCallback onAtras;

  const MenuProductosScreen({
    super.key,
    required this.onSiguiente,
    required this.onAtras,
  });

  @override
  State<MenuProductosScreen> createState() => _MenuProductosScreenState();
}

class _MenuProductosScreenState extends State<MenuProductosScreen> {
  // Instanciamos el servicio de productos
  final ProductsService _productsService = ProductsService();
  String _filtroBusqueda = '';
  final TextEditingController _buscarController = TextEditingController();

  // Lista simulada del menú original de Maru Food
  /*final List<Map<String, dynamic>> _productosDummy = [
    {
      'id': 'p1',
      'name': 'Hamburguesa',
      'priceUsd': 5.50,
      'costUsd': 3.00,
      'profitUsd': 2.50,
    },
    {
      'id': 'p2',
      'name': 'Hamburguesa Triple Queso dsadasdsa dasdasdasda dssadsadas',
      'priceUsd': 8.00,
      'costUsd': 4.20,
      'profitUsd': 3.80,
    },
    {
      'id': 'p3',
      'name': 'Papas Fritas Medianas',
      'priceUsd': 2.50,
      'costUsd': 1.00,
      'profitUsd': 1.50,
    },
    {
      'id': 'p4',
      'name': 'Refresco de Lata',
      'priceUsd': 1.50,
      'costUsd': 0.70,
      'profitUsd': 0.80,
    },
    {
      'id': 'p5',
      'name': 'Club House Maru',
      'priceUsd': 10.00,
      'costUsd': 5.50,
      'profitUsd': 4.50,
    },
  ];*/

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    /*final productosFiltrados = _productosDummy.where((prod) {
      return prod['name'].toString().toLowerCase().contains(
        _filtroBusqueda.toLowerCase(),
      );
    }).toList();*/

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderVerPedido(titulo: 'Paso 2: Selección de Productos'),
          const SizedBox(height: 12),

          // Buscador rápido
          TextField(
            controller: _buscarController,
            decoration: InputDecoration(
              labelText: 'Buscar producto...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _filtroBusqueda.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _buscarController.clear();
                          _filtroBusqueda = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (valor) => setState(() => _filtroBusqueda = valor),
          ),
          const SizedBox(height: 16),

          // Lista de productos del menú
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productsService.getProducts(
                onlyActive: true,
              ), // Trae solo activos en tiempo real
              builder: (context, snapshot) {
                // 1. Estado de Carga (Esperando conexión)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }
                // 2. Estado de Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar productos: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // 3. Obtener la lista cruda de Firestore
                final listaProductosFirebase = snapshot.data ?? [];

                // 4. Aplicar el filtro de búsqueda local
                final productosFiltrados = listaProductosFirebase.where((prod) {
                  return prod.name.toLowerCase().contains(
                    _filtroBusqueda.toLowerCase(),
                  );
                }).toList();

                // 5. Mostrar si está vacío
                if (productosFiltrados.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron productos.'),
                  );
                }

                // 6. Construir la Grid View con los objetos reales de tu modelo

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, // Ancho máximo de cada columna
                    crossAxisSpacing: 12, // Distancia horizontal entre tarjetas
                    mainAxisSpacing: 12, // Distancia vertical entre tarjetas
                    childAspectRatio:
                        0.65, // Mantiene la proporción en base al ancho calculado
                  ),
                  itemCount: productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = productosFiltrados[index];
                    final double precioUsd = producto.priceUsd;
                    final double precioBs = precioUsd * carrito.tasaCambio;

                    // Comprobación de unidades en el carrito
                    final indexEnCarrito = carrito.items.indexWhere(
                      (item) => item.productId == producto.id,
                    );
                    final int cantidadEnCarrito = indexEnCarrito >= 0
                        ? carrito.items[indexEnCarrito].quantity
                        : 0;

                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: cantidadEnCarrito > 0 ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: cantidadEnCarrito > 0
                              ? Colors.orange
                              : Colors.grey.shade300,
                          width: cantidadEnCarrito > 0 ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          // CAMBIO 1: Alinea todos los hijos en el eje horizontal hacia el centro
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Indicador superior dinámico
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fastfood_outlined,
                                  color: cantidadEnCarrito > 0
                                      ? Colors.orange
                                      : Colors.grey,
                                  size: 20,
                                ),
                                if (cantidadEnCarrito > 0) ...[
                                  const SizedBox(
                                    width: 4,
                                  ), // Pequeño espacio opcional entre icono y badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$cantidadEnCarrito u',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Nombre del Producto (Estilo Netflix)
                            Text(
                              producto.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign
                                  .center, // CAMBIO 2: Centra el texto si ocupa 1 o 2 líneas
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Precios en Divisa y Local
                            Text(
                              '\$${precioUsd.toStringAsFixed(2)}',
                              textAlign: TextAlign
                                  .center, // CAMBIO 3: Centra el texto del precio USD
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '${precioBs.toStringAsFixed(2)} Bs.',
                              textAlign: TextAlign
                                  .center, // CAMBIO 4: Centra el texto del precio Bs
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            //const Spacer(),
                            const SizedBox(height: 20),

                            // Botonera de control inferior interna de la tarjeta
                            cantidadEnCarrito > 0
                                ? Row(
                                    // CAMBIO 5: Agrupa los controles juntos en el centro en vez de dispersos (SpaceBetween)
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () => carrito.disminuirCantidad(
                                          producto.id,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      // Espaciado interno horizontal para separar los botones del número central
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0,
                                        ),
                                        child: Text(
                                          '$cantidadEnCarrito',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => carrito
                                            .incrementarCantidad(producto.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    // CAMBIO 6: Le damos un ancho específico (o puedes usar un Padding)
                                    // para que el botón "Agregar" no flote diminuto en el centro
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        final nuevoItem = ArticuloPedidoModel(
                                          productId: producto.id,
                                          name: producto.name,
                                          priceUsd: precioUsd,
                                          costUsd: producto.costUsd,
                                          profitUsd: producto.profitUsd,
                                          quantity: 1,
                                          totalUsd: precioUsd,
                                        );
                                        carrito.agregarProducto(nuevoItem);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.orange.shade50,
                                        foregroundColor: Colors.orange.shade900,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                      ),
                                      child: const Text(
                                        'Agregar',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Subtotal flotante
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items: ${carrito.items.fold(0, (sum, item) => sum + item.quantity)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Subtotal: \$${carrito.totalUsd.toStringAsFixed(2)} (${carrito.totalBs.toStringAsFixed(2)} Bs.)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botonera de Navegación
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onAtras,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('➔ Atrás', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: carrito.items.isEmpty ? null : widget.onSiguiente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Continuar a Pago ➔',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
