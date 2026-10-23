import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.enum.dart';
import '../../domain/usecases/check_role_access_usercase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class IdentityProvider with ChangeNotifier {
  // Inyección de los Casos de Uso del Dominio
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckRoleAccessUseCase _checkRoleAccessUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  IdentityProvider({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckRoleAccessUseCase checkRoleAccessUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _getCurrentUserUseCase = getCurrentUserUseCase,
       _checkRoleAccessUseCase = checkRoleAccessUseCase,
       _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase;

  // Estados privados
  UserEntity? _currentUser;
  bool _isLoading = true;

  // Getters públicos para que la UI los lea
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Getter rápido para el rol actual (por defecto cliente si no hay usuario)
  UserRole get userRole => _currentUser?.role ?? UserRole.cliente;

  /// Método para verificar si el usuario ya inició sesión al abrir la app (Splash / Inicio)
  Future<void> checkAuthSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llama al caso de uso del dominio
      _currentUser = await _getCurrentUserUseCase();
    } catch (e) {
      // Si ocurre un error durante la verificación de sesión, se puede manejar aquí o propagarlo hacia la UI
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método para validar accesos utilizando el caso de uso del dominio
  bool hasAccess(List<UserRole> allowedRoles) {
    // Llama al caso de uso del dominio
    return _checkRoleAccessUseCase(
      currentRole: userRole,
      allowedRoles: allowedRoles,
    );
  }

  /// Método para iniciar sesión (Login)
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _loginUseCase(email: email, password: password);
    } catch (e) {
      // Si ocurre un error durante el login, se puede manejar aquí o propagarlo hacia la UI
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método para Cerrar sesión (Logout)
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logoutUseCase();
      _currentUser = null;
    } catch (e) {
      // Si ocurre un error durante el logout, se puede manejar aquí o propagarlo hacia la UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos rápidos de validación
  bool get isAdmin => userRole == UserRole.admin;
  bool get isCocinero => userRole == UserRole.cocinero;
  bool get isRepartidor => userRole == UserRole.repartidor;
  bool get isCliente => userRole == UserRole.cliente;
}
