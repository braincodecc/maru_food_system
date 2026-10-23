import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/identity_local_datasource.dart';
import '../data/datasources/identity_remote_datasource.dart';
import '../data/repositories_impl/identity_repository_impl.dart';
import '../domain/usecases/check_role_access_usercase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../presentation/providers/identity_provider.dart';

/// Función fábrica que arma todo el árbol de dependencias del módulo Identity
IdentityProvider createIdentityProvider(SharedPreferences sharedPreferences) {
  // 1. Data Sources
  final localDataSource = IdentityLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final remoteDataSource = IdentityRemoteDataSourceImpl();

  // 2. Repository
  final repository = IdentityRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );

  // 3. Use Cases
  final getCurrentUserUseCase = GetCurrentUserUseCase(repository);
  final checkRoleAccessUseCase = CheckRoleAccessUseCase();
  final loginUseCase = LoginUseCase(repository);
  final logoutUseCase = LogoutUseCase(repository);

  // 4. Provider
  return IdentityProvider(
    getCurrentUserUseCase: getCurrentUserUseCase,
    checkRoleAccessUseCase: checkRoleAccessUseCase,
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
  );
}