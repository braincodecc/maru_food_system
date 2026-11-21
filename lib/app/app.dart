import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';

// Importación limpia de los módulos mediante sus barrel files
import '../features/identity/identity.dart';
import '../features/admin/admin.dart';
import '../features/client/client.dart';
//import '../features/ingredient/ingredient.dart';
//import '../features/order/order.dart';
//import '../features/finance/finance.dart';
import '../features/kitchen/kitchen.dart';
import '../features/delivery/delivery.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Módulo de Identidad (Carga el menú de Maru Food al instanciarse)
        ChangeNotifierProvider<IdentityProvider>(
          create: (_) =>
              createIdentityProvider(sharedPreferences)..checkAuthSession(),
        ),

        // Módulo de Cliente (Carga el menú de Maru Food al instanciarse)
        ChangeNotifierProvider<ClientProductProvider>(
          create: (_) => createClientProductProvider()..loadActiveProducts(),
        ),

        // Módulo de Cliente (Carga el menú de Maru Food al instanciarse)
        ChangeNotifierProvider<ClientOrderProvider>(
          create: (_) => createClientOrderProvider(),
        ),

        // Módulo de administrador (Carga los productos al iniciar)
        ChangeNotifierProvider<AdminProductProvider>(
          create: (_) => createAdminProductProvider()..loadProducts(),
        ),

        // Módulo de administrador (Carga los ingredientes al iniciar)
        ChangeNotifierProvider<AdminIngredientProvider>(
          create: (_) => createAdminIngredientProvider()..loadIngredients(),
        ),

        // Módulo de administrador (Carga las ordenes al iniciar)
        ChangeNotifierProvider<AdminOrderProvider>(
          create: (_) => createAdminOrderProvider()..loadOrders(),
        ),

        // Módulo de administrador (Carga las finanzas al iniciar)
        ChangeNotifierProvider<AdminFinanceProvider>(
          create: (_) => createAdminFinanceProvider()..loadAccounts(),
        ),

        // Módulo de Cocina
        ChangeNotifierProvider<KitchenProvider>(
          create: (_) => createKitchenProvider(),
        ),

        // Módulo de repartidor
        ChangeNotifierProvider<DeliveryProvider>(
          create: (_) => createDeliveryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Maru Food System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
        // Definimos la ruta inicial
        initialRoute: AppRoutes.initial,
        // Cargamos el mapa global de rutas con sus respectivos RoleGuards
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
