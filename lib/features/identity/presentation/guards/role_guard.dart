import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user_role.enum.dart';
import '../providers/identity_provider.dart';

class RoleGuard extends StatelessWidget {
  /// Lista de roles que tienen permitido ver este contenido o pantalla
  final List<UserRole> allowedRoles;

  /// El widget o pantalla protegida que se mostrará si tiene acceso
  final Widget child;

  /// Widget alternativo opcional en caso de que no tenga acceso (por defecto muestra una pantalla de error estándar)
  final Widget? fallbackWidget;

  const RoleGuard({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el IdentityProvider para reaccionar si el rol cambia o expira la sesión
    final identityProvider = context.watch<IdentityProvider>();

    // Validamos el acceso utilizando la lógica que definimos en el Provider/Dominio
    final bool hasAccess = identityProvider.hasAccess(allowedRoles);

    if (hasAccess) {
      return child;
    }

    // Si no tiene acceso, retornamos el fallback personalizado o la pantalla por defecto
    return fallbackWidget ?? const _DefaultAccessDeniedScreen();
  }
}

/// Pantalla por defecto que se muestra cuando el usuario no tiene permisos
class _DefaultAccessDeniedScreen extends StatelessWidget {
  const _DefaultAccessDeniedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Restringido'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'No tienes permisos para acceder a esta sección',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu rol actual no cuenta con las autorizaciones necesarias para visualizar este contenido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}