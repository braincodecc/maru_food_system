import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../order.dart';
import '../../../identity/identity.dart'; // Para acceder a IdentityProvider y obtener el usuario actual

class ClientActiveOrderScreen extends StatelessWidget {
  const ClientActiveOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    // Obtenemos el ID directamente del proveedor de autenticación de la app
    final authProvider = Provider.of<IdentityProvider>(context, listen: false);
    final clientId = authProvider.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Pedido en Curso - Maru Food'),
        backgroundColor: Colors.orange[800],
      ),
      body: StreamBuilder<OrderEntity?>(
        stream: provider.watchActiveOrder(clientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Ocurrió un error al cargar tu pedido:\n${snapshot.error.toString().replaceAll('Exception: ', '')}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final activeOrder = snapshot.data;

          // Estado: El cliente no tiene ninguna orden activa en este momento
          if (activeOrder == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fastfood_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes ningún pedido activo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cuando realices un nuevo pedido, podrás ver su estado y evolución en tiempo real aquí mismo.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Estado: El cliente tiene una orden activa en curso
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido #${activeOrder.id.substring(0, 6).toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Chip(
                          label: Text(activeOrder.status.name.toUpperCase()),
                          backgroundColor: Colors.orange[100],
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text(
                      'Estado actual:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusFriendlyDescription(activeOrder.status),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 10),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a cancelar:',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        Text(
                          '\$${activeOrder.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Método auxiliar para dar contexto amigable al cliente según el estado de su orden actual
  String _getStatusFriendlyDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingVerification:
        return 'El pago de tu pedido está pendiente de verificación.';
      case OrderStatus.approved:
        return '¡Manos a la obra! En Maru Food ya estamos preparando tu pedido.';
      case OrderStatus.delivered:
        return 'Tu pedido va en camino hacia la dirección de entrega.';
      case OrderStatus.rejected:
        return 'Tu pedido ha sido rechazado.';
      default:
        return 'Tu pedido está siendo procesado.';
    }
  }
}
