import '../entities/user_entity.dart';
import '../repositories/identity_repository.dart';

class GetCurrentUserUseCase {
  final IdentityRepository repository;

  GetCurrentUserUseCase(this.repository);

  // Al usar 'call', la clase se vuelve invocable
  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}