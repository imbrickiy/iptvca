import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF183e4b),
        onPrimary: Color(0xFFeaeaea),
        primaryContainer: Color(0xFF1b4552),
        onPrimaryContainer: Color(0xFFeaeaea),
        secondary: Color(0xFF8ba0a4),
        onSecondary: Color(0xFFeaeaea),
        secondaryContainer: Color(0xFF8ba0a4),
        onSecondaryContainer: Color(0xFF183e4b),
        tertiary: Color(0xFFd74a49),
        onTertiary: Color(0xFFeaeaea),
        error: Color(0xFFd74a49),
        onError: Color(0xFFeaeaea),
        errorContainer: Color(0xFFd74a49),
        onErrorContainer: Color(0xFFeaeaea),
        surface: Color(0xFFeaeaea),
        onSurface: Color(0xFF183e4b),
        surfaceContainerHighest: Color(0xFFeaeaea),
        onSurfaceVariant: Color(0xFF183e4b),
        outline: Color(0xFF8ba0a4),
        outlineVariant: Color(0xFF8ba0a4),
        shadow: Color(0xFF183e4b),
        scrim: Color(0xFF183e4b),
        inverseSurface: Color(0xFF183e4b),
        onInverseSurface: Color(0xFFeaeaea),
        inversePrimary: Color(0xFF8ba0a4),
        surfaceTint: Color(0xFF1b4552),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFeaeaea),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF183e4b),
        foregroundColor: Color(0xFFeaeaea),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFeaeaea),
        elevation: 2,
        shadowColor: const Color(0xFF183e4b).withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF183e4b),
          foregroundColor: const Color(0xFFeaeaea),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFd74a49),
        foregroundColor: Color(0xFFeaeaea),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8ba0a4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8ba0a4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF183e4b), width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF183e4b),
        textColor: Color(0xFF183e4b),
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFF8ba0a4).withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8ba0a4),
        onPrimary: Color(0xFF183e4b),
        primaryContainer: Color(0xFF1b4552),
        onPrimaryContainer: Color(0xFFeaeaea),
        secondary: Color(0xFF8ba0a4),
        onSecondary: Color(0xFF183e4b),
        secondaryContainer: Color(0xFF1b4552),
        onSecondaryContainer: Color(0xFFeaeaea),
        tertiary: Color(0xFFd74a49),
        onTertiary: Color(0xFFeaeaea),
        error: Color(0xFFd74a49),
        onError: Color(0xFFeaeaea),
        errorContainer: Color(0xFFd74a49),
        onErrorContainer: Color(0xFFeaeaea),
        surface: Color(0xFF183e4b),
        onSurface: Color(0xFFeaeaea),
        surfaceContainerHighest: Color(0xFF1b4552),
        onSurfaceVariant: Color(0xFF8ba0a4),
        outline: Color(0xFF8ba0a4),
        outlineVariant: Color(0xFF1b4552),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFeaeaea),
        onInverseSurface: Color(0xFF183e4b),
        inversePrimary: Color(0xFF183e4b),
        surfaceTint: Color(0xFF8ba0a4),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF183e4b),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1b4552),
        foregroundColor: Color(0xFFeaeaea),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1b4552),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1b4552),
          foregroundColor: const Color(0xFFeaeaea),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFd74a49),
        foregroundColor: Color(0xFFeaeaea),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1b4552),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8ba0a4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8ba0a4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8ba0a4), width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF8ba0a4),
        textColor: Color(0xFFeaeaea),
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFF8ba0a4).withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }
}

