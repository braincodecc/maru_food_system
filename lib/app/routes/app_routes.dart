import 'package:flutter/material.dart';

// Importas las pantallas desde sus respectivos módulos
import '../../features/identity/presentation/widgets/auth_wrapper.dart';
import '../../features/identity/presentation/screens/login_screen.dart';
import '../../features/identity/presentation/guards/role_guard.dart';
import '../../features/identity/domain/entities/user_role.enum.dart';

//import '../../features/product/presentation/screens/client_menu_screen.dart';
//import '../../features/product/presentation/screens/admin_product_form_screen.dart';
//import '../../features/kitchen/presentation/screens/kitchen_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String clientMenu = '/menu';
  static const String adminProducts = '/admin/products';
  static const String kitchen = '/kitchen';

  /// Mapa global de rutas de la aplicación
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const AuthWrapper(),
      login: (context) => const LoginScreen(),

      // Ruta protegida para clientes y administradores
      /*clientMenu: (context) => RoleGuard(
            allowedRoles: const [UserRole.cliente, UserRole.admin],
            child: const ClientMenuScreen(),
          ),*/

      // Ruta protegida EXCLUSIVA para el Administrador (Módulo Producto)
      /*adminProducts: (context) => RoleGuard(
            allowedRoles: const [UserRole.admin],
            child: const AdminProductFormScreen(),
          ),*/

      // Ruta protegida para Cocineros y Administradores (Módulo Cocina/KDS)
      /*kitchen: (context) => RoleGuard(
            allowedRoles: const [UserRole.cocinero, UserRole.admin],
            child: const KitchenScreen(),
          ),*/
    };
  }
}