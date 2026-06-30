import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maru_food_system/providers/app_providers.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'routes.dart';

void main() async {
  // Esto asegura que Flutter esté completamente inicializado antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ejecuta la app con el provider
  runApp(
    MultiProvider(
      providers: [
        // 🛒 UI State
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: AppProviders(child: const MaruFoodApp()),
    ),
  );
}

class MaruFoodApp extends StatelessWidget {
  const MaruFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maru Food System',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const SplashScreen(),
      routes: appRoutes,
    );
  }
}
