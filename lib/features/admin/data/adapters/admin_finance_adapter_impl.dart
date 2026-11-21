import '../../domain/ports/admin_finance_port.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_account_entity.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_transaction_entity.dart';
import 'package:maru_food_system/features/finance/domain/usecases/get_financial_accounts_usecase.dart';
import 'package:maru_food_system/features/finance/domain/usecases/get_transactions_by_account_usecase.dart';

class AdminFinanceAdapterImpl implements AdminFinancePort {
  final GetFinancialAccountsUseCase _getFinancialAccountsUseCase;
  final GetTransactionsByAccountUseCase _getTransactionsByAccountUseCase;

  AdminFinanceAdapterImpl({
    required GetFinancialAccountsUseCase getFinancialAccountsUseCase,
    required GetTransactionsByAccountUseCase getTransactionsByAccountUseCase,
  })  : _getFinancialAccountsUseCase = getFinancialAccountsUseCase,
        _getTransactionsByAccountUseCase = getTransactionsByAccountUseCase;

  @override
  Future<List<FinancialAccountEntity>> getAccounts() async {
    return await _getFinancialAccountsUseCase();
  }

  @override
  Future<List<FinancialTransactionEntity>> getTransactionsByAccount(
    String accountId,
  ) async {
    return await _getTransactionsByAccountUseCase(accountId);
  }
}