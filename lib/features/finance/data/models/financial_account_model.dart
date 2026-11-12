import '../../domain/entities/financial_account_entity.dart';

class FinancialAccountModel extends FinancialAccountEntity {
  const FinancialAccountModel({
    required super.id,
    required super.name,
    required super.description,
    required super.balance,
    required super.type,
  });

  factory FinancialAccountModel.fromMap(Map<String, dynamic> map, String id) {
    return FinancialAccountModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'balance': balance,
      'type': type,
    };
  }

  factory FinancialAccountModel.fromEntity(FinancialAccountEntity entity) {
    return FinancialAccountModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      balance: entity.balance,
      type: entity.type,
    );
  }

  FinancialAccountEntity toEntity() {
    return FinancialAccountEntity(
      id: id,
      name: name,
      description: description,
      balance: balance,
      type: type,
    );
  }
}