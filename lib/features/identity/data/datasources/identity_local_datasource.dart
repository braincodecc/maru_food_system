import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Contrato del Local DataSource
abstract class IdentityLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCacheUser();
}

/// Implementación usando SharedPreferences
class IdentityLocalDataSourceImpl implements IdentityLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Llave única para identificar los datos del usuario en las preferencias compartidas
  static const String cachedUserKey = 'CACHED_USER_KEY';

  IdentityLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    
    if (jsonString == null) {
      return null;
    }

    try {
      // Decodificamos el string JSON almacenado y lo convertimos a UserModel
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return UserModel.fromJson(jsonMap);
    } catch (e) {
      // Si el JSON se corrompió o hubo un error al parsear, limpiamos la caché y retornamos null
      await clearCacheUser();
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    // Convertimos el UserModel a un Map y luego a un String JSON
    final jsonString = jsonEncode(user.toJson());
    
    // Guardamos el string en SharedPreferences
    await sharedPreferences.setString(cachedUserKey, jsonString);
  }

  @override
  Future<void> clearCacheUser() async {
    // Eliminamos la llave del usuario al cerrar sesión
    await sharedPreferences.remove(cachedUserKey);
  }
}