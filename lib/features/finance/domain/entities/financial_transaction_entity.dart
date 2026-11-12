class FinancialTransactionEntity {
  final String id;
  final String accountId;     // A qué cuenta impacta
  final double amount;        // Monto de la transacción
  final String type;          // 'income' (ingreso) o 'expense' (retiro/gasto)
  final String concept;       // Ej: "Distribución orden #1025"
  final DateTime date;

  const FinancialTransactionEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.concept,
    required this.date,
  });
}