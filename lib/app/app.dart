import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
import '../features/identity/identity.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ¡El MultiProvider queda sumamente limpio y legible!
        ChangeNotifierProvider<IdentityProvider>(
          create: (_) =>
              createIdentityProvider(sharedPreferences)..checkAuthSession(),
        ),

        // Aquí agregarás en el futuro tus otros módulos (ej: CartProvider, OrderProvider, etc.)
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
