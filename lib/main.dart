import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:famai/firebase_options.dart';
import 'package:famai/screens/splash_screen.dart';
import 'package:famai/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Famai',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

