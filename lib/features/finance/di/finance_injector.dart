import '../data/datasources/finance_remote_datasource.dart';
import '../data/repositories_impl/finance_repository_impl.dart';
import '../domain/usecases/distribute_order_revenue_usecase.dart';
import '../domain/usecases/get_financial_accounts_usecase.dart';
import '../domain/usecases/get_transactions_by_account_usecase.dart';
import '../domain/usecases/transfer_account_funds_usecase.dart';

FinanceRepositoryImpl _createFinanceRepository() {
  final financeRemoteDataSource = FinanceRemoteDataSourceImpl();
  return FinanceRepositoryImpl(remoteDataSource: financeRemoteDataSource);
}

/// Usado por el adaptador financiero de Order
DistributeOrderRevenueUseCase createDistributeOrderRevenueUseCase() {
  return DistributeOrderRevenueUseCase(
    financeRepository: _createFinanceRepository(),
  );
}

/// Usado por el módulo Admin
GetFinancialAccountsUseCase createGetFinancialAccountsUseCase() {
  return GetFinancialAccountsUseCase(
    financeRepository: _createFinanceRepository(),
  );
}

/// Usado por el módulo Admin
GetTransactionsByAccountUseCase createGetTransactionsByAccountUseCase() {
  return GetTransactionsByAccountUseCase(
    financeRepository: _createFinanceRepository(),
  );
}

/// Usado por el módulo Admin
TransferAccountFundsUseCase createTransferAccountFundsUseCase() {
  return TransferAccountFundsUseCase(
    financeRepository: _createFinanceRepository(),
  );
}