import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  paid,
  completed,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {

  /// Texto legible para UI
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.paid:
        return 'Pagado';
      case OrderStatus.completed:
        return 'Preparado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Color del estado
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Conversión a string (Firestore)
  String get value => name;

  /// Conversión desde string (Firestore)
  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
}
