// 1. Exportar Dominio: Entidades y Enums (Entities & Enums)
export 'domain/entities/product_entity.dart';
export 'domain/entities/product_type.enum.dart';
export 'domain/entities/ingredient_entity.dart';

// 2. Exportar Presentación: Lógica de Negocio (Providers, Guards, Screens, Widgets)
export 'presentation/providers/product_provider.dart';
export 'presentation/screens/client_menu_screen.dart';

// 3. Exportar Inyección de Dependencias
export 'di/product_injector.dart';