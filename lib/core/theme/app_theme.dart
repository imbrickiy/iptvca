import 'package:flutter/material.dart';
import 'package:iptvca/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.onInverseSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarBackgroundLight,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackgroundLight,
        elevation: 2,
        shadowColor: AppColors.shadowColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.elevatedButtonBackgroundLight,
          foregroundColor: AppColors.elevatedButtonForeground,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.floatingActionButtonBackground,
        foregroundColor: AppColors.floatingActionButtonForeground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.inputFocusedBorder,
            width: 2,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.listTileIconLight,
        textColor: AppColors.listTileTextLight,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColorLight,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.secondary,
        onPrimary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.primary,
        secondaryContainer: AppColors.primaryContainer,
        onSecondaryContainer: AppColors.onPrimaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.primary,
        onSurface: AppColors.onPrimaryContainer,
        surfaceContainerHighest: AppColors.primaryContainer,
        onSurfaceVariant: AppColors.secondary,
        outline: AppColors.secondary,
        outlineVariant: AppColors.primaryContainer,
        shadow: AppColors.black,
        scrim: AppColors.black,
        inverseSurface: AppColors.surface,
        onInverseSurface: AppColors.primary,
        inversePrimary: AppColors.primary,
        surfaceTint: AppColors.secondary,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarBackgroundDark,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackgroundDark,
        elevation: 2,
        shadowColor: AppColors.shadowColorDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.elevatedButtonBackgroundDark,
          foregroundColor: AppColors.elevatedButtonForeground,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.floatingActionButtonBackground,
        foregroundColor: AppColors.floatingActionButtonForeground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.listTileIconDark,
        textColor: AppColors.listTileTextDark,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColorDark,
        thickness: 1,
      ),
    );
  }
}
