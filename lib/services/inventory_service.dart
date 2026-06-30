import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart';

class InventoryService {
  final _ref = FirebaseFirestore.instance.collection('inventory');

  /// Obtener insumos
  Stream<List<InventoryItemModel>> getItems() {
    return _ref.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => InventoryItemModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  /// Crear insumo
  Future<void> addItem(InventoryItemModel item) async {
    await _ref.add(item.toMap());
  }

  /// Actualizar insumo
  Future<void> updateItem(InventoryItemModel item) async {
    await _ref.doc(item.id).update(item.toMap());
  }

  Future<void> decreaseStock(String id, double qty) async {
    await _ref.doc(id).update({
      'quantity': FieldValue.increment(-qty),
    });
  }
  /// Activar / desactivar
  Future<void> toggleActive(InventoryItemModel item) async {
    await _ref.doc(item.id).update({
      'active': !item.active,
    });
  }
}
