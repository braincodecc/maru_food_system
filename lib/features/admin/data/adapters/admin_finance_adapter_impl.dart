import '../../domain/ports/admin_finance_port.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_account_entity.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_transaction_entity.dart';
import 'package:maru_food_system/features/finance/domain/usecases/get_financial_accounts_usecase.dart';
import 'package:maru_food_system/features/finance/domain/usecases/get_transactions_by_account_usecase.dart';
import 'package:maru_food_system/features/finance/domain/usecases/transfer_account_funds_usecase.dart';

class AdminFinanceAdapterImpl implements AdminFinancePort {
  final GetFinancialAccountsUseCase _getFinancialAccountsUseCase;
  final GetTransactionsByAccountUseCase _getTransactionsByAccountUseCase;
  final TransferAccountFundsUseCase _transferAccountFundsUseCase;

  AdminFinanceAdapterImpl({
    required GetFinancialAccountsUseCase getFinancialAccountsUseCase,
    required GetTransactionsByAccountUseCase getTransactionsByAccountUseCase,
    required TransferAccountFundsUseCase transferAccountFundsUseCase,
  }) : _getFinancialAccountsUseCase = getFinancialAccountsUseCase,
       _getTransactionsByAccountUseCase = getTransactionsByAccountUseCase,
       _transferAccountFundsUseCase = transferAccountFundsUseCase;

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

  @override
  Future<void> transferFundsToBank({
    required String accountId,
    required double currentBalance,
    required double amountToTransfer,
    required String bankReference,
    String? notes,
  }) async {
    await _transferAccountFundsUseCase(
      accountId: accountId,
      currentBalance: currentBalance,
      amountToTransfer: amountToTransfer,
      bankReference: bankReference,
      notes: notes,
    );
  }
}
