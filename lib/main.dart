// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'controllers/auth_controller.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/courses_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';

void main() {
  // The repository is built once and injected into the provider. This is the
  // composition root — the only place the concrete layers are wired together,
  // which keeps every other layer testable with fakes/mocks.
  final courseRepository = CourseRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (_) => CourseProvider(repository: courseRepository),
        ),
      ],
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
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.detail: (_) => const DetailScreen(),
        AppRoutes.courses: (_) => const CoursesScreen(),
      },
    );
  }
}
