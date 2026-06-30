import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exchange_rate.dart';

class ExchangeRateService {
  final _ref = FirebaseFirestore.instance
      .collection('settings')
      .doc('exchange_rate');

  Stream<ExchangeRate> getRate() {
    return _ref.snapshots().map(
          (doc) => ExchangeRate.fromFirestore(doc),
    );
  }

  Future<void> updateRate(double newRate) async {
    await _ref.set({
      'usdToBs': newRate,
      'updatedAt': Timestamp.now(),
    });
  }
}
