import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';

// Importación limpia de los módulos mediante sus barrel files
import '../features/identity/identity.dart';
import '../features/product/product.dart';

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

        // Módulo de Productos (Carga el menú de Maru Food al instanciarse)
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => createProductProvider()..loadActiveProducts(),
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
