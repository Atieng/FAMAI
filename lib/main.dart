import 'package:famai/providers/auth_provider.dart';
import 'package:famai/providers/calendar_provider.dart';
import 'package:famai/providers/chat_provider.dart';
import 'package:famai/providers/community_provider.dart';
import 'package:famai/providers/farm_provider.dart';
import 'package:famai/providers/scan_provider.dart';
import 'package:famai/providers/weather_provider.dart';
import 'package:famai/routes/app_routes.dart';
import 'package:famai/screens/auth/login_screen.dart';
import 'package:famai/screens/home/home_screen.dart';
import 'package:famai/screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        title: 'Famai',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            switch (auth.status) {
              case AuthStatus.uninitialized:
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              case AuthStatus.authenticated:
                return const MainScreen();
              case AuthStatus.unauthenticated:
                return const LoginScreen();
            }
          },
        ),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

