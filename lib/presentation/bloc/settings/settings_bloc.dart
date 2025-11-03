import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iptvca/domain/usecases/get_settings.dart';
import 'package:iptvca/domain/usecases/save_settings.dart';
import 'package:iptvca/presentation/bloc/settings/settings_event.dart';
import 'package:iptvca/presentation/bloc/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._getSettings,
    this._saveSettings,
  ) : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateAutoplayEvent>(_onUpdateAutoplay);
    on<UpdateVideoQualityEvent>(_onUpdateVideoQuality);
    on<UpdateThemeModeEvent>(_onUpdateThemeMode);
    on<UpdateShowNotificationsEvent>(_onUpdateShowNotifications);
    on<UpdateCacheEnabledEvent>(_onUpdateCacheEnabled);
    on<UpdateMaxCacheSizeEvent>(_onUpdateMaxCacheSize);
    on<SaveSettingsEvent>(_onSaveSettings);
  }

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final result = await _getSettings();
      result.fold(
        (failure) => emit(SettingsError(failure.message ?? 'Неизвестная ошибка')),
        (settings) => emit(SettingsLoaded(settings: settings)),
      );
    } catch (e) {
      developer.log('Ошибка загрузки настроек', error: e);
      emit(SettingsError('Ошибка загрузки настроек: $e'));
    }
  }

  void _onUpdateAutoplay(
    UpdateAutoplayEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        autoplay: event.autoplay,
      );
      emit(currentState.copyWith(settings: updatedSettings));
      add(const SaveSettingsEvent());
    }
  }

  void _onUpdateVideoQuality(
    UpdateVideoQualityEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        videoQuality: event.videoQuality,
      );
      emit(currentState.copyWith(settings: updatedSettings));
      add(const SaveSettingsEvent());
    }
  }

  void _onUpdateThemeMode(
    UpdateThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        themeMode: event.themeMode,
      );
      emit(currentState.copyWith(settings: updatedSettings));
      add(const SaveSettingsEvent());
    }
  }

  void _onUpdateShowNotifications(
    UpdateShowNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        showNotifications: event.showNotifications,
      );
      emit(currentState.copyWith(settings: updatedSettings));
      add(const SaveSettingsEvent());
    }
  }

  void _onUpdateCacheEnabled(
    UpdateCacheEnabledEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        cacheEnabled: event.cacheEnabled,
      );
      emit(currentState.copyWith(settings: updatedSettings));
      add(const SaveSettingsEvent());
    }
  }

  void _onUpdateMaxCacheSize(
    UpdateMaxCacheSizeEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        maxCacheSize: event.maxCacheSize,
      );
      emit(currentState.copyWith(settings: updatedSettings));
      add(const SaveSettingsEvent());
    }
  }

  Future<void> _onSaveSettings(
    SaveSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isSaving: true));
      try {
        final result = await _saveSettings(currentState.settings);
        result.fold(
          (failure) {
            developer.log('Ошибка сохранения настроек', error: failure.message);
            emit(SettingsError(failure.message ?? 'Неизвестная ошибка'));
          },
          (_) {
            emit(currentState.copyWith(isSaving: false));
          },
        );
      } catch (e) {
        developer.log('Ошибка сохранения настроек', error: e);
        emit(SettingsError('Ошибка сохранения настроек: $e'));
      }
    }
  }
}

