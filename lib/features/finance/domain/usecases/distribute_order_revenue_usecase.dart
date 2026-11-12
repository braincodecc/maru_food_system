import '../repositories/finance_repository.dart';
import '../entities/financial_transaction_entity.dart';
import 'package:maru_food_system/features/order/domain/entities/order_entity.dart';

class DistributeOrderRevenueUseCase {
  final FinanceRepository _financeRepository;

  DistributeOrderRevenueUseCase(this._financeRepository);

  Future<void> call(OrderEntity completedOrder) async {
    // 1. Calculamos los acumulados de la orden utilizando los items (con Snapshot)
    double totalRestockingFund = 0.0;
    double totalNetProfit = 0.0;

    for (var item in completedOrder.items) {
      totalRestockingFund += item.restockingFund; // unitCost * quantity
      totalNetProfit += item.netProfit;           // (unitPrice - unitCost) * quantity
    }

    // 2. Obtenemos las cuentas virtuales de la base de datos
    final restockingAccount = await _financeRepository.getAccountByType('restocking');
    final profitAccount = await _financeRepository.getAccountByType('profit_salary');

    if (restockingAccount == null || profitAccount == null) {
      throw Exception('Las cuentas contables de Maru Food no están inicializadas.');
    }

    // 3. Actualizamos saldos y registramos movimientos para la Cuenta de Reposición
    if (totalRestockingFund > 0) {
      final newRestockingBalance = restockingAccount.balance + totalRestockingFund;
      await _financeRepository.updateAccountBalance(restockingAccount.id, newRestockingBalance);
      
      await _financeRepository.recordTransaction(
        FinancialTransactionEntity(
          id: '', // Autogenerado en Data Source
          accountId: restockingAccount.id,
          amount: totalRestockingFund,
          type: 'income',
          concept: 'Ingreso por reposición - Orden #${completedOrder.id.substring(0, 6)}',
          date: DateTime.now(),
        ),
      );
    }

    // 4. Actualizamos saldos y registramos movimientos para la Cuenta de Sueldos/Gastos
    if (totalNetProfit > 0) {
      final newProfitBalance = profitAccount.balance + totalNetProfit;
      await _financeRepository.updateAccountBalance(profitAccount.id, newProfitBalance);

      await _financeRepository.recordTransaction(
        FinancialTransactionEntity(
          id: '',
          accountId: profitAccount.id,
          amount: totalNetProfit,
          type: 'income',
          concept: 'Ganancia neta (Sueldos) - Orden #${completedOrder.id.substring(0, 6)}',
          date: DateTime.now(),
        ),
      );
    }
  }
}