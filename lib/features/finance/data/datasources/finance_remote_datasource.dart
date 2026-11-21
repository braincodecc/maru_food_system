import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_account_model.dart';
import '../models/financial_transaction_model.dart';

abstract class FinanceRemoteDataSource {
  Future<List<FinancialAccountModel>> getAccounts();
  Future<FinancialAccountModel?> getAccountByType(String type);
  Future<void> updateAccountBalance(String accountId, double newBalance);
  Future<void> recordTransaction(FinancialTransactionModel transaction);
  Future<List<FinancialTransactionModel>> getTransactionsByAccount(
    String accountId,
  );
  Future<void> executeAccountTransfer({
    required String accountId,
    required double amountToTransfer,
    required FinancialTransactionModel transaction,
  });
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final FirebaseFirestore _firestore;

  FinanceRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _accountsRef =>
      _firestore.collection('financial_accounts');
  CollectionReference get _transactionsRef =>
      _firestore.collection('financial_transactions');

  @override
  Future<List<FinancialAccountModel>> getAccounts() async {
    final snapshot = await _accountsRef.get();
    return snapshot.docs.map((doc) {
      return FinancialAccountModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  @override
  Future<FinancialAccountModel?> getAccountByType(String type) async {
    final snapshot = await _accountsRef
        .where('type', isEqualTo: type)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return FinancialAccountModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  @override
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    await _accountsRef.doc(accountId).update({'balance': newBalance});
  }

  @override
  Future<void> recordTransaction(FinancialTransactionModel transaction) async {
    await _transactionsRef.add(transaction.toMap());
  }

  @override
  Future<List<FinancialTransactionModel>> getTransactionsByAccount(
    String accountId,
  ) async {
    final snapshot = await _transactionsRef
        .where('accountId', isEqualTo: accountId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return FinancialTransactionModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  @override
  Future<void> executeAccountTransfer({
    required String accountId,
    required double amountToTransfer,
    required FinancialTransactionModel transaction,
  }) async {
    final accountRef = _firestore
        .collection('financial_accounts')
        .doc(accountId);
    final transactionRef = _firestore
        .collection('financial_transactions')
        .doc();

    await _firestore.runTransaction((tx) async {
      // 1. Lectura atómica del saldo real en servidor
      final accountSnap = await tx.get(accountRef);
      if (!accountSnap.exists) {
        throw Exception('La cuenta contable no existe.');
      }

      final serverBalance =
          (accountSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      if (amountToTransfer > serverBalance) {
        throw Exception(
          'Saldo insuficiente en servidor. Disponible: \$${serverBalance.toStringAsFixed(2)}',
        );
      }

      final newBalance = serverBalance - amountToTransfer;

      // 2. Escrituras atómicas: si una falla, ninguna se aplica
      tx.update(accountRef, {'balance': newBalance});
      tx.set(transactionRef, transaction.toMap());
    });
  }
}
