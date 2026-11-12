class OrderItemEntity {
  final String productId;      
  final String productName;    // Nombre congelado (Snapshot)
  final double unitPrice;      // Precio de venta congelado (Snapshot)
  final double unitCost;       // Costo de producción congelado (Snapshot) 💡 NUEVO
  final double quantity;       

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unitCost,
    required this.quantity,
  });

  // Totales de la línea
  double get subtotal => unitPrice * quantity; // Dinero total que ingresó
  
  double get restockingFund => unitCost * quantity; // Dinero intocable para reponer mercancía
  
  double get netProfit => (unitPrice - unitCost) * quantity; // Ganancia real para sueldos/gastos
}