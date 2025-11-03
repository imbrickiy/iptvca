import 'package:flutter/material.dart';
import 'package:iptvca/domain/entities/settings.dart' as entities;

extension AppThemeModeExtension on entities.AppThemeMode {
  ThemeMode toThemeMode() {
    switch (this) {
      case entities.AppThemeMode.system:
        return ThemeMode.system;
      case entities.AppThemeMode.light:
        return ThemeMode.light;
      case entities.AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

