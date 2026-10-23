import '../repositories/identity_repository.dart';

class LogoutUseCase {
  final IdentityRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
