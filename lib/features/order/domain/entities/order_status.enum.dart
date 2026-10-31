enum OrderStatus {
  awaitingPayment,     // Stock reservado, esperando que el cliente pague y mande referencia
  pendingVerification, // Esperando que el admin verifique el Pago Móvil
  approved,            // Pago aprobado, stock descontado definitivamente, pasa a cocina
  rejected,            // Pago falso o no encontrado, stock devuelto al almacén
  delivered,           // Pedido entregado al cliente
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.awaitingPayment:
        return 'Esperando Pago';
      case OrderStatus.pendingVerification:
        return 'Pendiente de Verificación';
      case OrderStatus.approved:
        return 'Aprobado / En Preparación';
      case OrderStatus.rejected:
        return 'Rechazado';
      case OrderStatus.delivered:
        return 'Entregado';
    }
  }
}