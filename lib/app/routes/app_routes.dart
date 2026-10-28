import 'package:flutter/material.dart';

// Importaciones limpias utilizando ÚNICAMENTE los archivos Barrel globales de cada módulo
import '../../features/identity/identity.dart';
import '../../features/product/product.dart';
import '../../features/ingredient/ingredient.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String clientMenu = '/menu';
  static const String adminProducts = '/admin/products';
  static const String adminDashboardProducts = '/admin/dashboard/Products';
  static const String adminIngredients = '/admin/ingredients';
  static const String kitchen = '/kitchen';

  /// Mapa global de rutas de la aplicación
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // 1. Ruta Inicial manejada por el AuthWrapper del módulo de Identidad
      initial: (context) => const AuthWrapper(),

      // 2. Login
      login: (context) => const LoginScreen(),

      // 3. Menú del Cliente (Protegido por RoleGuard)
      clientMenu: (context) => RoleGuard(
        allowedRoles: const [UserRole.cliente, UserRole.admin],
        child: const ClientMenuScreen(),
      ),

      // 4. Formulario de Administración de Productos (Protegido para Admin)
      adminProducts: (context) => RoleGuard(
        allowedRoles: const [UserRole.admin],
        child: const AdminProductFormScreen(),
      ),

      // 5. Panel Principal del Administrador protegido por RoleGuard
      adminDashboardProducts: (context) => RoleGuard(
        allowedRoles: const [UserRole.admin],
        child: const AdminDashboardScreen(),
      ),

      // 6. Gestión de Ingredientes (Protegido para Admin)
      adminIngredients: (context) => RoleGuard(
        allowedRoles: const [UserRole.admin],
        child: const AdminIngredientsScreen(),
      ),

      // Ruta protegida para Cocineros y Administradores (Módulo Cocina/KDS)
      /*kitchen: (context) => RoleGuard(
            allowedRoles: const [UserRole.cocinero, UserRole.admin],
            child: const KitchenScreen(),
          ),*/
    };
  }
}
