import '../entities/financial_account_entity.dart';
import '../entities/financial_transaction_entity.dart';

abstract class FinanceRepository {
  Future<List<FinancialAccountEntity>> getAccounts();
  Future<FinancialAccountEntity?> getAccountByType(String type);
  Future<void> updateAccountBalance(String accountId, double newBalance);
  Future<void> recordTransaction(FinancialTransactionEntity transaction);
  Future<List<FinancialTransactionEntity>> getTransactionsByAccount(String accountId);
}