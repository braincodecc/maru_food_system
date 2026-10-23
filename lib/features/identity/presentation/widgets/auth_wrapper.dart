import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user_role.enum.dart';
import '../providers/identity_provider.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';

// Importa las pantallas Home de tus otros módulos:
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../client/presentation/screens/client_home_screen.dart';
import '../../../kitchen/presentation/screens/kitchen_home_screen.dart';
import '../../../delivery/presentation/screens/delivery_home_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    // 1. Si está cargando la sesión inicial, muestra el Splash
    if (identityProvider.isLoading) {
      return const SplashScreen();
    }

    // 2. Si no está autenticado, muestra el Login
    if (!identityProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // 3. Si está autenticado, redirige según su rol de comida rápida
    switch (identityProvider.userRole) {
      case UserRole.admin:
        return const AdminDashboardScreen(); // O la pantalla que corresponda
      case UserRole.cliente:
        return const ClientHomeScreen();
      case UserRole.repartidor:
        return const DeliveryHomeScreen();
      case UserRole.cocinero:
        return const KitchenHomeScreen();
    }
  }
}