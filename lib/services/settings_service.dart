import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final _docRef = FirebaseFirestore.instance
      .collection('settings')
      .doc('exchange_rate');

  /// Obtener tasa de cambio (stream)
  Stream<double> getExchangeRate() {
    return _docRef.snapshots().map((doc) {
      if (!doc.exists) return 0.0;
      return (doc.data()?['usdToBs'] ?? 0).toDouble();
    });
  }

  /// Guardar / actualizar tasa
  Future<void> updateExchangeRate(double rate) async {
    await _docRef.set({
      'usdToBs': rate,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
