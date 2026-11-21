import 'package:maru_food_system/features/finance/domain/entities/financial_account_entity.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_transaction_entity.dart';

abstract class AdminFinancePort {
  Future<List<FinancialAccountEntity>> getAccounts();
  Future<List<FinancialTransactionEntity>> getTransactionsByAccount(String accountId);
}