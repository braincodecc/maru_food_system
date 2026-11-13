enum OrderStatus {
  awaitingPayment('awaitingPayment'),         // Stock reservado, esperando pago del cliente
  pendingVerification('pendingVerification'), // Cliente envió referencia, esperando verificación del admin
  approved('approved'),                       // Pago aprobado por el admin, listo para cocina
  inPreparation('inPreparation'),             // Cocinero tomó la orden y la está preparando
  ready('ready'),                             // Pedido listo (Pickup: espera al cliente; Delivery: espera repartidor)
  outForDelivery('outForDelivery'),           // Pedido en camino con el repartidor
  delivered('delivered'),                     // Pedido entregado al cliente / retirado con éxito
  completed('completed'),                     // Finalizado, ingresos distribuidos automáticamente a cuentas virtuales
  rejected('rejected');                       // Pago inválido o rechazado, stock devuelto al almacén

  // Valor que normalmente viene del backend (String)
  final String value;
  const OrderStatus(this.value);

  // Método utilitario para convertir String a Enum de forma segura
  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == status.toUpperCase(),
      orElse: () => OrderStatus.awaitingPayment, // Estado por defecto
    );
  }
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.awaitingPayment:
        return 'Esperando Pago';
      case OrderStatus.pendingVerification:
        return 'Pendiente de Verificación';
      case OrderStatus.approved:
        return 'Aprobado';
      case OrderStatus.inPreparation:
        return 'En Preparación';
      case OrderStatus.ready:
        return 'Listo para Despacho';
      case OrderStatus.outForDelivery:
        return 'En Camino (Delivery)';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.rejected:
        return 'Rechazado';
    }
  }
}