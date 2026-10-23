import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.enum.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.avatarUrl,
  });

  // Mapear desde la respuesta de una API (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  // Mapear hacia JSON para enviar al servidor o guardar localmente
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.value,
      'avatar_url': avatarUrl,
    };
  }
}
