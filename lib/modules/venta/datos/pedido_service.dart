import 'package:cloud_firestore/cloud_firestore.dart';
import 'pedido_model.dart';

/// [PedidoService] es la evolución híbrida de orders_service.dart.
/// Se conecta a Firestore para registrar ventas rápidas y consultar flujos pendientes.
class PedidoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Registra una nueva venta express o pedido directamente en la colección 'orders' de Firestore.
  /// No rompemos tu base de datos actual porque seguimos apuntando a la colección 'orders'.
  Future<void> crearPedidoExpress(PedidoModel pedido) async {
    try {
      // .add() genera el ID aleatorio automáticamente en Firestore
      DocumentReference docRef = await _db.collection('orders').add(pedido.toMap());
      
      // Guardamos ese ID autogenerado dentro del mismo documento por comodidad en futuras consultas
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print("Error en PedidoService al registrar la venta: $e");
      rethrow;
    }
  }

  /// Trae un flujo en tiempo real (Stream) de todas las ventas express
  /// que quedaron pendientes de revisión para el cierre administrativo nocturno.
  Stream<List<PedidoModel>> obtenerPedidosPendientesNocturnos() {
    return _db
        .collection('orders')
        .where('isPendingAdminEnrichment', isEqualTo: true)
        // Ordenamos cronológicamente para que atiendas primero los más viejos de la jornada
        .orderBy('createdAt', descending: false) 
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Reconstruimos usando el factory optimizado de tu modelo híbrido
            return PedidoModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }
}