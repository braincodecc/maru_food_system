import '../entities/user_entity.dart';

abstract class IdentityRepository {
  /// Obtiene el usuario actual (desde caché local o servidor)
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> login({required String email, required String password});
  Future<void> logout();

  // Opcional: si necesitas un método en el repositorio que consulte al servidor
  // si la sesión sigue activa o si el token expiró:
  // Future<UserEntity?> checkServerSession();
}
