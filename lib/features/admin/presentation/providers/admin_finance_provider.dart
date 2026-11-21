import 'package:flutter/foundation.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_account_entity.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_transaction_entity.dart';
import '../../domain/ports/admin_finance_port.dart';

class AdminFinanceProvider extends ChangeNotifier {
  final AdminFinancePort _adminFinancePort;

  AdminFinanceProvider({required AdminFinancePort adminFinancePort})
    : _adminFinancePort = adminFinancePort;

  List<FinancialAccountEntity> _accounts = [];
  List<FinancialTransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FinancialAccountEntity> get accounts => _accounts;
  List<FinancialTransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _adminFinancePort.getAccounts();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactionsForAccount(String accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _adminFinancePort.getTransactionsByAccount(
        accountId,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerBankTransfer({
    required String accountId,
    required double currentBalance,
    required double amountToTransfer,
    required String bankReference,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminFinancePort.transferFundsToBank(
        accountId: accountId,
        currentBalance: currentBalance,
        amountToTransfer: amountToTransfer,
        bankReference: bankReference,
        notes: notes,
      );
      // Recargamos las cuentas para actualizar el saldo disponible en pantalla
      await loadAccounts();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
