// 1. Exportar Dominio: Entidades y Enums (Entities & Enums)
export 'domain/entities/order_entity.dart';
export 'domain/entities/order_status.enum.dart';

// 2. Exportar Presentación: Lógica de Negocio (Providers, Guards, Screens, Widgets)
export 'presentation/providers/order_provider.dart';
export 'presentation/screens/checkout_screen.dart';

// 3. Exportar Inyección de Dependencias
export 'di/order_injector.dart';