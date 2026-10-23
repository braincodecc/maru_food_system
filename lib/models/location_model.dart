class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'],
    );
  }

  /// NUEVO MÉTODO: Intenta extraer coordenadas desde un texto o enlace del portapapeles
  factory LocationModel.fromWhatsAppClipboard(String textoPortapapeles) {
    try {
      // Expresión regular para capturar coordenadas comunes (Ej: 10.2443,-67.5912)
      final RegExp regExpCoordenadas = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
      final match = regExpCoordenadas.firstMatch(textoPortapapeles);

      if (match != null && match.groupCount >= 2) {
        double lat = double.parse(match.group(1)!);
        double lng = double.parse(match.group(2)!);
        
        return LocationModel(
          latitude: lat,
          longitude: lng,
          address: "Ubicación pegada desde WhatsApp",
        );
      }
      
      // Si es un enlace acortado tipo maps.app.goo.gl, requerirá una petición HTTP 
      // para resolver la URL real. Por ahora, si no encuentra el patrón directo,
      // puedes lanzar un error controlado o devolver coordenadas en 0.
      throw Exception("No se encontraron coordenadas válidas en el texto.");
    } catch (e) {
      print("Error al procesar el portapapeles: $e");
      rethrow;
    }
  }
}