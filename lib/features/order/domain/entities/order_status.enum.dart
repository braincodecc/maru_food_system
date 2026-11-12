enum OrderStatus {
  awaitingPayment,     // Stock reservado, esperando que el cliente pague y mande referencia
  pendingVerification, // Esperando que el admin verifique el Pago Móvil
  approved,            // Pago aprobado, stock descontado definitivamente, pasa a cocina
  rejected,            // Pago falso o no encontrado, stock devuelto al almacén
  delivered,           // Pedido entregado al cliente
  completed,           // Pedido finalizado, ingresos distribuidos a cuentas virtuales
  inPreparation,        // Pedido en preparación, stock descontado definitivamente, pasa a cocina
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
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.inPreparation:
        return 'En Preparación';
    }
  }
}