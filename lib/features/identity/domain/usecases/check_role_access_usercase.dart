import '../entities/user_role.enum.dart';

class CheckRoleAccessUseCase {
  /// Verifica si un rol determinado tiene permiso basándose en una lista de roles permitidos.
  bool call({
    required UserRole currentRole,
    required List<UserRole> allowedRoles,
  }) {
    // Regla de negocio: Si el rol actual está en la lista de permitidos, tiene acceso.
    return allowedRoles.contains(currentRole);
  }
}
