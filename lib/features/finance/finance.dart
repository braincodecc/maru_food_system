// 1. Exportar Dominio: Entidades y Enums (Entities & Enums)
export 'domain/entities/financial_account_entity.dart';
export 'domain/entities/financial_transaction_entity.dart';

// 2. Exportar Presentación: Lógica de Negocio (Providers, Guards, Screens, Widgets)
export 'presentation/providers/finance_provider.dart';
export 'presentation/screens/finance_dashboard_screen.dart';

// 3. Exportar Inyección de Dependencias
export 'di/finance_injector.dart';