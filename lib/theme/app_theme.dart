import 'package:flutter/material.dart';

class AppTheme {
  static const Color primario = Color(0xFF4F46E5);
  static const Color secundario = Color(0xFF7C3AED);
  static const Color fondo = Color(0xFFF8FAFC);

  static ThemeData get temaClaro {
    final esquema = ColorScheme.fromSeed(
      seedColor: primario,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
