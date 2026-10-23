import 'package:flutter/material.dart';
import 'package:maru_food_system/models/location_model.dart'; // Asegúrate de importar tu modelo de ubicación

/// [FlujoVentaProvider] gestiona la memoria temporal de las tres pantallas 
/// del módulo de venta en caliente antes de enviarlo   a Cloud Firestore.
class FlujoVentaProvider with ChangeNotifier {
  String _customerName = 'Cliente Express';
  String _customerPhone = '';
  
  /// NUEVO: Ahora es un objeto estructurado y nulleable
  LocationModel? _customerLocation; 

  // Getters
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  LocationModel? get customerLocation => _customerLocation;

  // Setters y métodos de actualización
  void actualizarNombre(String nombre) {
    _customerName = nombre.isEmpty ? 'Cliente Express' : nombre;
    notifyListeners();
  }

  void actualizarTelefono(String telefono) {
    _customerPhone = telefono;
    notifyListeners();
  }

  /// Método para cuando el cajero presiona "Pegar Ubicación desde WhatsApp"
  void procesarYGuardarUbicacion(String textoDelPortapapeles) {
    try {
      // Usamos el método extractor que creamos con Expresiones Regulares
      _customerLocation = LocationModel.fromWhatsAppClipboard(textoDelPortapapeles);
      notifyListeners();
    } catch (e) {
      _customerLocation = null;
      notifyListeners();
      rethrow; 
    }
  }

  /// Método para resetear el flujo después de una venta exitosa
  void limpiarFlujo() {
    _customerName = 'Cliente Express';
    _customerPhone = '';
    _customerLocation = null;
    notifyListeners();
  }
}