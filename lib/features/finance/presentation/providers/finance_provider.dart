import 'package:flutter/foundation.dart';
import '../../domain/entities/financial_account_entity.dart';
import '../../domain/entities/financial_transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  // Repositorio temporalmente, pendiente creación de los casos de uso de cuentas y transacciones para el módulo de Finanzas (no deberia manejar repositorios) 
  final FinanceRepository _financeRepository;

  FinanceProvider({
    required FinanceRepository financeRepository,
  })  : _financeRepository = financeRepository;

  List<FinancialAccountEntity> _accounts = [];
  List<FinancialTransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FinancialAccountEntity> get accounts => _accounts;
  List<FinancialTransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga todas las cuentas financieras contables (Reposición y Sueldos)
  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _financeRepository.getAccounts();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga las transacciones recientes asociadas a una cuenta específica
  Future<void> loadTransactionsForAccount(String accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _financeRepository.getTransactionsByAccount(accountId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método expuesto por si se requiere disparar la distribución de manera manual desde la UI
  /*Future<bool> distributeRevenueManually(OrderEntity orderEntity) async {
    try {
      await _distributeOrderRevenueUseCase(orderEntity);
      await loadAccounts(); // Recargamos saldos actualizados
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }*/
}