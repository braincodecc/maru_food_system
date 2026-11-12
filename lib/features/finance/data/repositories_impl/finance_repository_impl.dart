import '../../domain/entities/financial_account_entity.dart';
import '../../domain/entities/financial_transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_datasource.dart';
import '../models/financial_account_model.dart';
import '../models/financial_transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepositoryImpl({required FinanceRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<FinancialAccountEntity>> getAccounts() async {
    try {
      final models = await _remoteDataSource.getAccounts();
      return models
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las cuentas financieras: $e');
    }
  }

  @override
  Future<FinancialAccountEntity?> getAccountByType(String type) async {
    try {
      final model = await _remoteDataSource.getAccountByType(type);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Error al buscar cuenta por tipo ($type): $e');
    }
  }

  @override
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _remoteDataSource.updateAccountBalance(accountId, newBalance);
    } catch (e) {
      throw Exception('Error al actualizar saldo de la cuenta $accountId: $e');
    }
  }

  @override
  Future<void> recordTransaction(FinancialTransactionEntity transaction) async {
    try {
      final model = FinancialTransactionModel.fromEntity(transaction);
      await _remoteDataSource.recordTransaction(model);
    } catch (e) {
      throw Exception('Error al registrar transacción financiera: $e');
    }
  }

  @override
  Future<List<FinancialTransactionEntity>> getTransactionsByAccount(
    String accountId,
  ) async {
    try {
      final models = await _remoteDataSource.getTransactionsByAccount(accountId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception(
        'Error al obtener transacciones de la cuenta $accountId: $e',
      );
    }
  }
}
