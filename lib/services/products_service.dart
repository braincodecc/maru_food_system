import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductsService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    'products',
  );

  /// Obtener productos activos
  Stream<List<Product>> getProducts({bool onlyActive = true}) {
    //Query query = _ref.orderBy('name');
    Query query = _ref;

    if (onlyActive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                Product.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Crear producto
  Future<void> addProduct(Product product) async {
    await _ref.add(product.toMap());
  }

  /// Actualizar producto
  Future<void> updateProduct(Product product) async {
    await _ref.doc(product.id).update(product.toMap());
  }

  /// Activar / desactivar
  Future<void> toggleActive(Product product) async {
    await _ref.doc(product.id).update({'active': !product.active});
  }

}
