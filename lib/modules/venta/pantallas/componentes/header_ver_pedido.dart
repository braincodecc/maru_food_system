import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../detalle_pedido_modal.dart';
import '../../gestores/carrito_provider.dart';

class HeaderVerPedido extends StatelessWidget {
  final String titulo;

  const HeaderVerPedido({
    super.key,
    required this.titulo, // Pasamos el titulo como parámetro para que cambie según la pantalla.
  });

  // Centralizamos el método para abrir el modal aquí adentro
  /// Despliega el detalle del pedido desde la parte inferior
  void _verDetalleDePedido(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // ⚡ SOLUCIÓN: Evita que el modal tape o se meta debajo de la barra de Android
      //useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DetallePedidoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del carrito (ajusta 'CarritoProvider' al nombre de tu clase)
    final carrito = Provider.of<CarritoProvider>(context);

    return Wrap(
      // Al igual que MainAxisAlignment.spaceBetween, distribuye el espacio horizontal
      alignment: WrapAlignment.spaceBetween,
      // Centra verticalmente los elementos cuando están en la misma línea
      crossAxisAlignment: WrapCrossAlignment.center,
      // Distancia horizontal entre el texto y el botón en caso de estar juntos
      spacing: 8.0,
      // Distancia vertical entre el texto y el botón cuando se posiciona abajo
      runSpacing: 8.0,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        // Botón para revisar la orden actual
        TextButton.icon(
          onPressed: carrito.items.isEmpty
              ? null
              : () => _verDetalleDePedido(context),
          icon: Badge(
            label: Text(
              '${carrito.items.fold(0, (sum, item) => sum + item.quantity)}',
            ),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          label: const Text('Ver Pedido'),
        ),
      ],
    );
  }
}
