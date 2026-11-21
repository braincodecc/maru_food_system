import '../entities/financial_account_entity.dart';
import '../repositories/finance_repository.dart';

class GetFinancialAccountsUseCase {
  final FinanceRepository _financeRepository;

  GetFinancialAccountsUseCase({required FinanceRepository financeRepository})
      : _financeRepository = financeRepository;

  Future<List<FinancialAccountEntity>> call() async {
    return await _financeRepository.getAccounts();
  }
}