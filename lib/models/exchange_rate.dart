import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeRate {
  final double usdToBs;
  final DateTime updatedAt;

  ExchangeRate({required this.usdToBs, required this.updatedAt});

  factory ExchangeRate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExchangeRate(
      usdToBs: (data['usdToBs'] ?? 0).toDouble(),
      updatedAt: DateTime.now(),
    );
  }
}
