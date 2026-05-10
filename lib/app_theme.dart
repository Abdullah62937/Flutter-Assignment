// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color bg          = Color(0xFF1C1A17);
  static const Color bgCard      = Color(0xFF252219);
  static const Color bgSurface   = Color(0xFF2E2B22);
  static const Color bgElevated  = Color(0xFF38342A);

  static const Color amber       = Color(0xFFF5A623);
  static const Color amberLight  = Color(0xFFFFD580);
  static const Color amberDark   = Color(0xFFB97A0A);

  static const Color teal        = Color(0xFF2ABFBF);
  static const Color rose        = Color(0xFFE05C5C);
  static const Color sage        = Color(0xFF7DBF7D);

  static const Color textPrimary   = Color(0xFFF2EDD8);
  static const Color textSecondary = Color(0xFFABA68F);
  static const Color textHint      = Color(0xFF5C5847);

  static const Color border        = Color(0xFF3D3929);
  static const Color borderFocus   = Color(0xFF8A7040);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.amber,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        secondary: AppColors.teal,
        surface: AppColors.bgCard,
        background: AppColors.bg,
        error: AppColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.rose)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.rose, width: 1.5)),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        errorStyle: const TextStyle(color: AppColors.rose, fontSize: 12),
        prefixIconColor: AppColors.textHint,
        suffixIconColor: AppColors.textHint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((s) => s.contains(MaterialState.selected) ? AppColors.amber : Colors.transparent),
        checkColor: MaterialStateProperty.all(AppColors.bg),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class AppRoutes {
  static const String register  = '/register';
  static const String login     = '/login';
  static const String dashboard = '/dashboard';
  static const String detail    = '/detail';
}
