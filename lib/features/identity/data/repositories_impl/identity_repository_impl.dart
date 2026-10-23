import 'package:maru_food_system/features/identity/data/datasources/identity_local_datasource.dart';
import 'package:maru_food_system/features/identity/data/datasources/identity_remote_datasource.dart';
import 'package:maru_food_system/features/identity/domain/entities/user_entity.dart';
import 'package:maru_food_system/features/identity/domain/repositories/identity_repository.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  final IdentityRemoteDataSource remoteDataSource;
  final IdentityLocalDataSource localDataSource;

  IdentityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // 1. Primero intentamos recuperar la sesión desde la caché local (rápido y offline-friendly)
      final localUser = await localDataSource.getCachedUser();
      if (localUser != null) {
        return localUser;
      }

      // 2. Si no hay nada en caché, consultamos al servidor remoto (Firebase Auth + Firestore)
      final remoteUser = await remoteDataSource.getCurrentUser();

      if (remoteUser != null) {
        // 3. Guardamos en caché local para las siguientes consultas
        await localDataSource.cacheUser(remoteUser);
      }

      return remoteUser;
    } catch (e) {
      // Si ocurre un error de red o lectura, retornamos null de forma segura
      return null;
    }
  }
  
  @override
  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.login(email, password);
    if (user != null) {
      await localDataSource.cacheUser(user);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearCacheUser();
  }

}
