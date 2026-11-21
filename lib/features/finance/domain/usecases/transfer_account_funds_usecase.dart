import '../entities/financial_transaction_entity.dart';
import '../repositories/finance_repository.dart';

class TransferAccountFundsUseCase {
  final FinanceRepository _financeRepository;

  TransferAccountFundsUseCase({required FinanceRepository financeRepository})
    : _financeRepository = financeRepository;

  Future<void> call({
    required String accountId,
    required double currentBalance,
    required double amountToTransfer,
    required String bankReference,
    String? notes,
  }) async {
    if (amountToTransfer <= 0) {
      throw Exception('El monto a transferir debe ser mayor a \$0.00.');
    }

    if (amountToTransfer > currentBalance) {
      throw Exception(
        'Saldo insuficiente. Disponible: \$${currentBalance.toStringAsFixed(2)}',
      );
    }

    final conceptDetail = notes != null && notes.trim().isNotEmpty
        ? 'Transferencia a banco (Ref: $bankReference) - $notes'
        : 'Transferencia a banco (Ref: $bankReference)';

    final transaction = FinancialTransactionEntity(
      id: '',
      accountId: accountId,
      amount: amountToTransfer,
      type: 'expense',
      concept: conceptDetail,
      date: DateTime.now(),
    );

    await _financeRepository.executeAccountTransfer(
      accountId: accountId,
      amountToTransfer: amountToTransfer,
      transaction: transaction,
    );
  }
}
