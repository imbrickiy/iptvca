
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    MediaKit.ensureInitialized();
    await InjectionContainer.instance.init();
    runApp(const MyApp());
  } catch (e, stackTrace) {
    developer.log(
      'Ошибка инициализации приложения: $e',
      name: 'main',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(
      MaterialApp(
        title: AppConstants.appName,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Ошибка инициализации приложения',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
          surfaceVariant: Color(0xFF8ba0a4),
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
          shadowColor: const Color(0xFF183e4b).withOpacity(0.2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF183e4b),
            foregroundColor: const Color(0xFFeaeaea),
            elevation: 2,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFd74a49),
          foregroundColor: Color(0xFFeaeaea),
        ),
      ),
      darkTheme: ThemeData(
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
          surfaceVariant: Color(0xFF1b4552),
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
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1b4552),
            foregroundColor: const Color(0xFFeaeaea),
            elevation: 2,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFd74a49),
          foregroundColor: Color(0xFFeaeaea),
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
