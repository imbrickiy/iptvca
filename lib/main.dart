import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/core/theme/app_theme.dart';
import 'package:iptvca/core/theme/theme_extension.dart';
import 'package:iptvca/presentation/bloc/settings/settings_bloc.dart';
import 'package:iptvca/presentation/bloc/settings/settings_event.dart';
import 'package:iptvca/presentation/bloc/settings/settings_state.dart';
import 'package:iptvca/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await windowManager.ensureInitialized();
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = InjectionContainer.instance.createSettingsBloc()
      ..add(const LoadSettingsEvent());
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final themeMode = state is SettingsLoaded
              ? state.settings.themeMode.toThemeMode()
              : ThemeMode.system;
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
