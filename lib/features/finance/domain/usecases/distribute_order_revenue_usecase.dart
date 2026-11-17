import '../../domain/repositories/finance_repository.dart';
import '../../domain/entities/financial_transaction_entity.dart';
import '../../../order/domain/entities/order_entity.dart'; // O puedes recibir los datos primitivos si quieres aislamiento total

class DistributeOrderRevenueUseCase {
  final FinanceRepository _financeRepository;

  DistributeOrderRevenueUseCase({required FinanceRepository financeRepository})
      : _financeRepository = financeRepository;

  Future<void> call(OrderEntity completedOrder) async {
    double totalRestockingFund = 0.0;
    double totalNetProfit = 0.0;

    for (var item in completedOrder.items) {
      totalRestockingFund += item.restockingFund;
      totalNetProfit += item.netProfit;
    }

    final restockingAccount = await _financeRepository.getAccountByType('restocking');
    final profitAccount = await _financeRepository.getAccountByType('profit_salary');

    if (restockingAccount == null || profitAccount == null) {
      throw Exception('Las cuentas contables de Maru Food no están inicializadas.');
    }

    if (totalRestockingFund > 0) {
      await _financeRepository.updateAccountBalance(
        restockingAccount.id,
        restockingAccount.balance + totalRestockingFund,
      );

      await _financeRepository.recordTransaction(
        FinancialTransactionEntity(
          id: '',
          accountId: restockingAccount.id,
          amount: totalRestockingFund,
          type: 'income',
          concept: 'Ingreso por reposición - Orden #${completedOrder.id.substring(0, 6)}',
          date: DateTime.now(),
        ),
      );
    }

    if (totalNetProfit > 0) {
      await _financeRepository.updateAccountBalance(
        profitAccount.id,
        profitAccount.balance + totalNetProfit,
      );

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