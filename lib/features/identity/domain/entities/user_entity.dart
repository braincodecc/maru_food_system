import 'package:equatable/equatable.dart';
import 'user_role.enum.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  // Getter utilitario para verificar permisos rápidamente en la UI
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, email, name, role, avatarUrl];
}
