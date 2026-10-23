import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'firebase_options.dart';
//import 'package:provider/provider.dart';
//import 'routes.dart';
//import 'providers/cart_provider.dart';
//import 'package:maru_food_system/modules/venta/gestores/carrito_provider.dart';
//import 'package:maru_food_system/modules/venta/gestores/flujo_venta_provider.dart';
//import 'features/identity/identity.dart';
//import 'features/identity/identity.dart';
//import 'features/identity/di/identity_injector.dart';

void main() async {
  // Esto asegura que Flutter esté completamente inicializado antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreferences = await SharedPreferences.getInstance();

  // Ejecuta la app con el provider
  runApp(MyApp(sharedPreferences: sharedPreferences));
}
