// 1. Exportar Dominio: Entidades y Enums (Entities & Enums)
export 'domain/entities/user_entity.dart';
export 'domain/entities/user_role.enum.dart';

// 2. Exportar Presentación: Lógica de Negocio (Providers, Guards, Screens, Widgets)
export 'presentation/providers/identity_provider.dart';
export 'presentation/guards/role_guard.dart';
export 'presentation/widgets/auth_wrapper.dart';
export 'presentation/screens/login_screen.dart';

// 3. Exportar Inyección de Dependencias
export 'di/identity_injector.dart';