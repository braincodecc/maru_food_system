class FinancialAccountEntity {
  final String id;
  final String name;          // Ej: "Cuenta Reposición", "Cuenta Sueldos/Gastos"
  final String description;
  final double balance;       // Saldo actual reflejado
  final String type;          // 'restocking' (reabastecimiento) o 'profit_salary' (ganancias/sueldos)

  const FinancialAccountEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.balance,
    required this.type,
  });
}