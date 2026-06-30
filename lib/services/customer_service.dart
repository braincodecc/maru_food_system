import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/location_model.dart';

class CustomerService {
  final CollectionReference<Map<String, dynamic>> _db = FirebaseFirestore
      .instance
      .collection('customers');

  Future<CustomerModel?> getByPhone(String phone) async {
    final normalizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final query = await _db.where('phone', isEqualTo: normalizedPhone).limit(1).get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return CustomerModel.fromMap(doc.id, doc.data());
  }
  Future<List<CustomerModel>> searchByPhone(String phonePrefix) async {
    final normalized = phonePrefix.replaceAll(RegExp(r'\s+'), '');

    if (normalized.length < 4) return [];

    final query = await _db
        .where('phone', isGreaterThanOrEqualTo: normalized)
        .where('phone', isLessThan: '$normalized\uf8ff')
        .limit(5)
        .get();

    return query.docs
        .map((d) => CustomerModel.fromMap(d.id, d.data()))
        .toList();
  }
  Future<CustomerModel> create({required String name, required String phone, required String address, required LocationModel location}) async {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone.replaceAll(RegExp(r'\s+'), ''),
      'address': address,
      'location': location.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
    };

    final docRef = await _db.add(data);
    final snapshot = await docRef.get();

    return CustomerModel.fromMap(snapshot.id, snapshot.data()!);
  }
  Future<void> update({required String id, required Map<String, dynamic> data}) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.doc(id).update(data);
  }
  /*
  /// Crear cliente
  Future<CustomerModel> create(CustomerModel customer) async {
    final doc = await _db.add(customer.toMap());
    return CustomerModel(
      id: doc.id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      location: customer.location,
      createdAt: customer.createdAt,
      lastOrderAt: customer.lastOrderAt,
      active: customer.active,
    );
  }

  /// Crear o devolver cliente existente por teléfono
  Future<CustomerModel> createOrGetCustomer({
    required String name,
    required String phone,
    String? address,
    required LocationModel location,
  }) async {
    // 1️⃣ Normalizar teléfono
    final normalizedPhone = phone.replaceAll(RegExp(r'\s+'), '');

    // 2️⃣ Buscar cliente por teléfono
    final query = await _db
        .where('phone', isEqualTo: normalizedPhone)
        .limit(1)
        .get();

    // 3️⃣ Si existe → devolver y actualizar datos si aplica
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;

      final data = doc.data() as Map<String, dynamic>;

      final Map<String, dynamic> updates = {
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 👉 Actualizar address si vino nuevo
      if (address != null && address.isNotEmpty) {
        updates['address'] = address;
      }

      // 👉 Actualizar ubicación SOLO si es diferente o no existe
      if (data['location'] == null) {
        updates['location'] = location.toMap();
      }

      if (updates.length > 1) {
        await doc.reference.update(updates);
      }

      return CustomerModel.fromMap(
        doc.id,
        {...data, ...updates},
      );
    }

    // 4️⃣ Si NO existe → crear cliente nuevo
    final docRef = await _db.add({
      'name': name,
      'phone': normalizedPhone,
      'address': address,
      'location': location.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final newDoc = await docRef.get();

    return CustomerModel.fromMap(
      newDoc.id,
      newDoc.data() as Map<String, dynamic>,
    );
  }

  /// Actualizar cliente
  Future<void> update({required String id, required Map<String, dynamic> data}) async {
    await _db.doc(id).update(data);
  }
  /*Future<void> update(CustomerModel customer) {
    return _ref.doc(customer.id).update(customer.toMap());
  }*/

  /// Buscar cliente por teléfono
  Future<CustomerModel?> getByPhone(String phone) async {
    final query = await _db.where('phone', isEqualTo: phone).limit(1).get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return CustomerModel.fromMap(doc.id, doc.data());
  }

  /// Buscar clientes por prefijo de teléfono (autocomplete)
  Future<List<CustomerModel>> searchByPhone(String phonePrefix) async {
    final normalized = phonePrefix.replaceAll(RegExp(r'\s+'), '');

    if (normalized.length < 4) return [];

    final query = await _db
        .where('phone', isGreaterThanOrEqualTo: normalized)
        .where('phone', isLessThan: '$normalized\uf8ff')
        .limit(5)
        .get();

    return query.docs
        .map((d) => CustomerModel.fromMap(d.id, d.data()))
        .toList();
  }

  /// Obtener clientes activos
  Stream<List<CustomerModel>> streamAll({bool onlyActive = true}) {
    Query<Map<String, dynamic>> query = _db.orderBy(
      'createdAt',
      descending: true,
    );

    if (onlyActive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map(
      (s) => s.docs.map((d) => CustomerModel.fromMap(d.id, d.data())).toList(),
    );
  }
  */
}
