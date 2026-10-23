enum UserRole {
  admin('admin'),
  cocinero('cocinero'),
  repartidor('repartidor'),
  cliente('cliente');

  // Valor que normalmente viene del backend (String)
  final String value;
  const UserRole(this.value);

  // Método utilitario para convertir String a Enum de forma segura
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value.toUpperCase() == role.toUpperCase(),
      orElse: () => UserRole.cliente, // Rol por defecto
    );
  }
}
