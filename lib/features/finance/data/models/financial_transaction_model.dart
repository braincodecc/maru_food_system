import '../../domain/entities/financial_transaction_entity.dart';

class FinancialTransactionModel extends FinancialTransactionEntity {
  const FinancialTransactionModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.type,
    required super.concept,
    required super.date,
  });

  factory FinancialTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return FinancialTransactionModel(
      id: id,
      accountId: map['accountId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      concept: map['concept'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'amount': amount,
      'type': type,
      'concept': concept,
      'date': date.toIso8601String(),
    };
  }

  factory FinancialTransactionModel.fromEntity(FinancialTransactionEntity entity) {
    return FinancialTransactionModel(
      id: entity.id,
      accountId: entity.accountId,
      amount: entity.amount,
      type: entity.type,
      concept: entity.concept,
      date: entity.date,
    );
  }

  FinancialTransactionEntity toEntity() {
    return FinancialTransactionEntity(
      id: id,
      accountId: accountId,
      amount: amount,
      type: type,
      concept: concept,
      date: date,
    );
  }
}