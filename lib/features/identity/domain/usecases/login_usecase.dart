import '../entities/user_entity.dart';
import '../repositories/identity_repository.dart';

class LoginUseCase {
  final IdentityRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
