// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'controllers/auth_controller.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.register,
      routes: {
        AppRoutes.register:  (_) => const RegisterScreen(),
        AppRoutes.login:     (_) => const LoginScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.detail:    (_) => const DetailScreen(),
      },
    );
  }
}
