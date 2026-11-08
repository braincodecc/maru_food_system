import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

extension FirebaseSafeCallExtension on Future {
  /// Envuelve cualquier llamada a Firebase/Firestore y traduce sus errores de forma limpia
  Future<T> guard<T>() async {
    try {
      return await this as T;
    } on FirebaseException catch (e) {
      debugPrint('🔥 FirebaseException [${e.code}]: ${e.message}');

      // 1. Si el mensaje nativo de Firebase trae texto descriptivo importante, lo usamos directamente
      if (e.message != null && e.message!.isNotEmpty) {
        // Limpiamos o traducimos solo si es necesario, de lo contrario pasamos el mensaje real
        throw Exception(e.message);
      }

      // 2. Si no tiene mensaje, aplicamos respaldos por código
      switch (e.code) {
        case 'unavailable':
        case 'network-request-failed':
          throw Exception(
            'Sin conexión a internet. Verifica tu red e intenta de nuevo.',
          );
        case 'permission-denied':
          throw Exception(
            'No tienes permisos suficientes para realizar esta operación.',
          );
        case 'not-found':
          throw Exception(
            'El registro solicitado no fue encontrado en el servidor.',
          );
        case 'resource-exhausted':
          throw Exception(
            'Se ha superado el límite de peticiones. Intenta más tarde.',
          );
        case 'failed-precondition':
          throw Exception(
            'La operación no pudo completarse debido a un conflicto de datos. Intenta nuevamente.',
          );
        default:
          throw Exception('Ocurrió un error en la base de datos (${e.code}).');
      }
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socketexception') ||
          errorString.contains('network')) {
        throw Exception('Error de red. Comprueba tu conexión a internet.');
      }
      throw Exception(
        'Error inesperado: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }
}
