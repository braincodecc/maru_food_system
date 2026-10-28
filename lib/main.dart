import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'firebase_options.dart';

void main() async {
  // Esto asegura que Flutter esté completamente inicializado antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreferences = await SharedPreferences.getInstance();

  // Ejecuta la app con el provider
  runApp(MyApp(sharedPreferences: sharedPreferences));
}
