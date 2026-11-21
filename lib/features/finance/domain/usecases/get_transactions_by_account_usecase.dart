import '../entities/financial_transaction_entity.dart';
import '../repositories/finance_repository.dart';

class GetTransactionsByAccountUseCase {
  final FinanceRepository _financeRepository;

  GetTransactionsByAccountUseCase({required FinanceRepository financeRepository})
      : _financeRepository = financeRepository;

  Future<List<FinancialTransactionEntity>> call(String accountId) async {
    return await _financeRepository.getTransactionsByAccount(accountId);
  }
}