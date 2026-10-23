// 1. Exportar Entidades y Enums del Dominio
export 'domain/entities/user_entity.dart';
export 'domain/entities/user_role.enum.dart';

// 2. Exportar el Provider global y Guard de Acceso
export 'presentation/providers/identity_provider.dart';
export 'presentation/guards/role_guard.dart';
export 'presentation/widgets/auth_wrapper.dart';
export 'presentation/screens/login_screen.dart';
export 'di/identity_injector.dart';